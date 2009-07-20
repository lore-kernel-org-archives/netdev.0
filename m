From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Mon, 20 Jul 2009 08:41:38 +0200
Message-ID: <200907200841.38968.oliver@neukum.org>
References: <1247824566-9141-1-git-send-email-remi.denis-courmont@nokia.com> <200907171547.39815.oliver@neukum.org> <200907200935.19103.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200907200935.19103.remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Montag, 20. Juli 2009 08:35:18 schrieb R=C3=A9mi Denis-Courmont:
> Recurrently:
> If usbpn_xmit() is called, then the queue was not stopped, so tx_queu=
e <
> tx_queue_len. Then the queue is stopped. In the race free cases, eith=
er
> tx_queue is incremented up to the limit, and the queue remains stoppe=
d; the
> assertion is still valid.
> Alternatively tx_queue remains below limit and the queue gets woken a=
gain;
> the assertion is still valid.

Yes, you are correct. I find no flaws with the driver.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
