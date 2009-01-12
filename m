From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: another race in hso
Date: Mon, 12 Jan 2009 15:02:55 +0100
Message-ID: <200901121502.56716.oliver@neukum.org>
References: <200812221454.57794.oliver@neukum.org> <200901121436.16576.oliver@neukum.org> <496B4B39.3090908@option.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <496B4B39.3090908-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Monday 12 January 2009 14:52:57 schrieb Denis Joseph Barrow:
> > You can change that back, although if you need flags, you shouldn't
> > use types that indicate a specific word length. That's outright evil.
> Well chars are 1 byte in most architectures the most neutral bitfield
> definition that most people go by for flags is unsigned int but I'll

char is fine. u8 is not. u8 says you need 8 bit, no more, no less.
Now, if you need just one bit, why not tell the compiler?

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
