From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [patch]startup race in hso driver
Date: Mon, 12 Jan 2009 11:57:37 +0100
Message-ID: <200901121157.38962.oliver@neukum.org>
References: <200812181457.36340.oliver@neukum.org> <496B1556.3010901@option.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org, "Greg Kroah-Hartman" <gregkh-l3A5Bk7waGM@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <496B1556.3010901-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Monday 12 January 2009 11:03:02 schrieb Denis Joseph Barrow:
> Hi Oliver,
> Is the patch below now obselete?
> I applied it to our internal tree, should I remove it?

Hi,

this patch is still needed. It fixes a completely different issue
than the second, large patch I sent later. This patch solves
a race between startup and urb completion. The second patch
fixes a race between xmit and autosuspend.

Earlier today you wanted your patches broken down by bugs
they fix, so you've already gotten what you wanted ;-)

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
