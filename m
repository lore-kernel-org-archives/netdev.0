From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Wed, 3 Jun 2015 13:07:34 +0300
Message-ID: <556ED1E6.8050907@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1432647280.28905.107.camel@redhat.com>
 <20150526165928.GC11800@obsidianresearch.com>
 <1432662396.28905.157.camel@redhat.com> <5567169C.60206@mellanox.com>
 <20150528154633.GB2962@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150528154633.GB2962-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 28/05/2015 18:46, Jason Gunthorpe wrote:
> On Thu, May 28, 2015 at 04:22:36PM +0300, Haggai Eran wrote:
>> wouldn't care if they share the "QP number namespace", etc. RDMA CM
>> ports are different because they are chosen by the applications, but
>> they map directly to the network namespace, so they don't require their
>> own namespace.
> 
> Different containers should have restricted access to the PKey and GID
> tables, and the presence device itself. Just like in the SRIOV
> case.
> 
> That is what the 'RDMA Namespace' would control.

We were thinking here that there is a room for an RDMA cgroup. It would
limit the amount of RDMA resources a container can use. It can also be
used for the restrictions you mentioned, but maybe they are more
suitable for a namespace. I'm not sure. In RoCE for instance, a
restricted access to the GID table can be derived from the network
namespace directly, but perhaps not in InfiniBand.

Regards,
Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
