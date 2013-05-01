From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: Regression in 3.9 caused by "bridge: respect RFC2863
 operational state"
Date: Wed, 1 May 2013 15:49:04 -0700
Message-ID: <20130501154904.0ea31991@nehalam.linuxnetplumber.net>
References: <518166C5.4080904@openwrt.org>
	<CABPxzYLP53mnMXAicD33oX8TW77xnZziS=XBuVCy_u4H2oyLUw@mail.gmail.com>
	<CAOaVG179Rx_JfV99mbjWhwQTALb5gh+2_WVFWDSbngA0qkzoGw@mail.gmail.com>
	<518183C8.8050606@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Krishna Chaitanya <chaitanya.mgit-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sebastian Gottschall <s.gottschall-t37Kgv3TaIPQT0dZR+AlfA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <518183C8.8050606-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 01 May 2013 23:06:16 +0200
Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org> wrote:

> On 2013-05-01 10:21 PM, Stephen Hemminger wrote:
> > What about using AF_PACKET bound to underlying wireless device and the
> > packet type. You can even use BPF to filter.
> As far as I know, AF_PACKET only works when not binding it to the packet
> type (otherwise it get stolen by the rx handler).

You can do AF_PACKET and it gets handle before rx_handler.

> Not binding it to the packet type and using BPF to filter is expensive
> on small embedded devices with small caches. Still, this requires
> userspace changes, so we need a different solution.
> 
> > Another alternative would be to have bridge accept control frames on
> > dormant device but not send.
> Sounds good, will you send a patch for that?
> 
> - Felix
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
