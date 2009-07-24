From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Sat, 25 Jul 2009 00:19:57 +0100
Message-ID: <20090725001957.1241e968@lxorguk.ukuu.org.uk>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com>
	<200907241431.08858.oliver@neukum.org>
	<20090724134805.0d9496be@lxorguk.ukuu.org.uk>
	<200907241612.41871.oliver@neukum.org>
	<1248458401.28545.149.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	=?ISO-8859-14?B?UultaQ==?= Denis-Courmont
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	ext Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1248458401.28545.149.camel@violet>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> we don't want PPP at all. It is just plain stupid and a total braindead
> idea. Non of the GSM/UMTS networks talk PPP over the air interface or
> actually anywhere in their stack. The PPP is just between the host OS
> and the card. It is a pointless encapsulation of IP packets that comes
> from the POTS stuff where PPP over a telephone line made sense.

Well yes. A 3G USB modem is a lovely example of compatibility gone mad

It runs

	an emulated PPP session
	over an emulated serial port
	over a serial port multiplex emulating multiple serial ports
	over an emulated serial port
	over a USB link which has perfectly good packet facilities
	into the Linux kernel
	which makes it look like a legacy modem device
	which is managed by a set of software tools written for 9600 baud
		modems


Unfortunately fixing that has to start at the vendor firmware end, and
that is a lot of interfaces for SMS, voice dialing, fax and god knows
what else as well as data.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
