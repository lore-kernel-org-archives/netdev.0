From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH ] cdc_ncm: fixes for big-endian architecture / MIPS
Date: Tue, 2 Aug 2011 20:30:21 +0200
Message-ID: <201108022030.21331.oliver@neukum.org>
References: <1312302026-7077-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1312302026-7077-1-git-send-email-alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 2. August 2011, 18:20:26 schrieb Alexey Orishko:
> Changes:
> - removed redandunt conversion for usb control requests
> - added missing conversion for nth16.wNdpIndex
> Thanks to Giuseppe Scrivano for providing fixes

What? How can a conversion of endianness be redundant?
Either this version or the old version must be buggy. What is
happening here?

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
