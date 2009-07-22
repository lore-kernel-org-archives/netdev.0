From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Wed, 22 Jul 2009 10:41:51 +0200
Message-ID: <200907221041.51995.oliver@neukum.org>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com> <1248184373.6558.15.camel@localhost.localdomain> <200907221137.07005.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ext Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ext Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
To: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200907221137.07005.remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 22. Juli 2009 10:37:06 schrieb R=C3=A9mi Denis-Courmont:
> I guess in a perfect world, Linux would provide a common control inte=
rface
> for GPRS as it already does WiFi (and maybe soon will for WiMAX?). Bu=
t I am
> not sure we can unify AT+PPP, Phonet, AT+Ethernet and who knows what =
else,
> behind a common Netlink interface, especially as AT commands have alw=
ays
> been done in userland anyway.

The AT stuff is really problematic. Look at the hoops ISDN and software
modem drivers go through to emulate AT commands. I know even of a CDC-A=
CM
modem which can't deal with AT commands inline (that's within spec).
It seems to me we should have a modem API in kernel.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
