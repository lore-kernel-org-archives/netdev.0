From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Fri, 24 Jul 2009 16:12:41 +0200
Message-ID: <200907241612.41871.oliver@neukum.org>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com> <200907241431.08858.oliver@neukum.org> <20090724134805.0d9496be@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	ext Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090724134805.0d9496be-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Freitag, 24. Juli 2009 14:48:05 schrieb Alan Cox:
> > No, I was thinking of having two full devices, a data channel and a
> > control channel for devices that really talk AT commands natively.
>
> If the hardware does it great, however for things like a 3G modem you
> have the problem that the PPP is over the AT command channel which may
> itself be multiplexed. And the muxing in question is *ugly* - sort of
> HDLC and LAP-B done wrong.

Well, yes, but we would really like a separate control channel, so we
can query parameters like signal strength, while we do PPP over the data
channel.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
