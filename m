From: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Patch] infiniband: check local reserved ports
Date: Mon, 07 Jun 2010 17:04:16 +0800
Message-ID: <4C0CB610.4010305@redhat.com>
References: <20100603083106.6047.7657.sendpatchset@localhost.localdomain>	<ada1vcoqde3.fsf@roland-alpha.cisco.com> <4C085C9A.30506@redhat.com> <ada1vcmpyvu.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <ada1vcmpyvu.fsf-BjVyx320WGW9gfZ95n9DRSW4+XlvGpQz@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/05/10 00:04, Roland Dreier wrote:
>   >  >  Should this inet_is_reserved_local_port() test apply to all the "port
>   >  >  spaces" that this code is handling?  I honestly am ignorant of the
>   >  >  intended semantics of the new local_reserved_ports stuff, hence my question.
>
>   >  Yes, but I only found this case, is there any else?
>
> My question was more in the other direction: should this test apply to
> all the "port spaces" handled here?  From looking at the code, it
> appears the answer is yes -- it seems that putting a port in
> local_reserved_ports reserves that port for IPv4 and IPv6, UDP, TCP,
> SCTP, DCCP, everything, so we should probably reserve all RDMA CM ports too.

Yes.

So this patch looks good for you? :)

Thanks.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
