From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: Regression in 3.9 caused by "bridge: respect RFC2863
 operational state"
Date: Tue, 19 Jan 2016 13:48:32 -0800
Message-ID: <20160119134832.3ab2f04b@xeon-e3>
References: <CAFuUQkhHsRZMnNYBbVZU0=BcAKMEktzYgPv6oc=CMFd7MFDi6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
	kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, Krishna Chaitanya <chaitanya.mgit-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sebastian Gottschall <s.gottschall-t37Kgv3TaIPQT0dZR+AlfA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, hostap-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: YanBo <dreamfly281-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAFuUQkhHsRZMnNYBbVZU0=BcAKMEktzYgPv6oc=CMFd7MFDi6g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 3 Dec 2015 18:29:00 -0800
YanBo <dreamfly281-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Sorry to pick up this thread again,  it looks this issue still existed  in
> the newer 4.3 kernel. (The EAP frames can not be received by wireless
> interface due to the bridge interface,
> http://marc.info/?l=linux-wireless&m=136743495526905&w=2)
> 
> Wonder is anyone know some update for this issue?  Currently the only
> workaround is make the 4-address  AP and STA associated in security mode
> firstly and then create the bridge, the renew key configuration also need
> be disable at the hostapd side to  avoid renew the key at bridge status.
> 
> Thanks
> Yanbo

How does wireless device indicate that is up?  It may just be that
the code is missing the logic to propagate operstate correctly.
This is normally done by netif_stacked_transfer_operstate and linkwatch
event.

Also STP can be disabled if you don't need it.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
