From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 5/7] net: Add allocation flag to rtnl_unicast()
Date: Fri, 08 Jul 2016 06:00:31 +0200
Message-ID: <1467950431.17638.6.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
	 <1467764916-4983-6-git-send-email-masashi.honma@gmail.com>
	 <1467946591.1273.45.camel@edumazet-glaptop3.roam.corp.google.com>
	 <577F1AD7.8040800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org,
	dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org, pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Masashi Honma <masashi.honma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <577F1AD7.8040800-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-07-08 at 12:15 +0900, Masashi Honma wrote:
=
> Thanks for comment.
> 
> I have selected GFP flags based on existing code.
> 
> I have selected GFP_ATOMIC in inet6_netconf_get_devconf() because
> skb was allocated with GFP_ATOMIC.

Point is : we should remove GFP_ATOMIC uses as much as we can.

Everytime we see one of them, we should think why it was added
and if this is really needed.

inet6_netconf_get_devconf() is a perfect example of one careless
GFP_ATOMIC usage

https://patchwork.ozlabs.org/patch/646291/






--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
