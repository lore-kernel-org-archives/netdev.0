From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] CDC_NCM adding support IFF_NOARP for infineon modem
 platform
Date: Wed, 16 Jan 2013 16:18:37 -0500 (EST)
Message-ID: <20130116.161837.1786136462165772470.davem@davemloft.net>
References: <1358183953.1713.28.camel@dcbw.foobar.com>
	<20130114.133412.479351928049237212.davem@davemloft.net>
	<87hamikfpc.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87hamikfpc.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Tue, 15 Jan 2013 09:34:07 +0100

> The main problem is that these devices don't support ethernet.  They
> support IP (v4 and _maybe_ v6) with an ethernet header.  Many of them
> will do ARP (and IPv6 ND) as well to complete the picture, but some o=
f
> them don't and that's what these drivers try to deal with.

Ok, in that case setting IFF_NOARP is in fact the right thing to do.
Thanks for describing the situation.

Someone please resubmit the patch to do that and I'll apply it.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
