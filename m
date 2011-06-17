From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: Re: [PATCH 05/14] SIWv2: User interface: siw_verbs.h, siw_verbs.c,
 siw_user.h, siw_ae.c
Date: Fri, 17 Jun 2011 09:20:35 -0500
Message-ID: <4DFB62B3.5050108@opengridcomputing.com>
References: <OF7426A1EE.BBD67937-ONC12578B2.003B466D-C12578B2.004E3647@ch.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <OF7426A1EE.BBD67937-ONC12578B2.003B466D-C12578B2.004E3647-Xeyd2O9EBijQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/17/2011 09:14 AM, Bernard Metzler wrote:
> Steve,
> we currently do not support inline data for kernel clients since
> we copy those data into a malloc'd buffer, where kmalloc()
> might block. Using an explicit buffer comes from experiments
> to allow for larger blocks of inlined data.
> I could put the inline data directly into the wqe restricting it
> to some 200 bytes or less (dependent on wqe size which
> is mainly determined by numer of sge's supported).
> would that make sense? maybe it would better reflect the
> intended nature of inline data - put some bytes out w/o
> doing memory registration...

I assume the intention of SEND_INLINE was precisely to allow putting the data into the HW WQE to avoid an additional DMA 
fetch of small payloads for HW RDMA devices.  For SWIW, this is not really an issue.


Steve.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
