From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] NET: cdc-phonet, handle empty phonet header
Date: Mon, 14 Mar 2011 09:49:04 +0200
Message-ID: <201103140949.04760.remi.denis-courmont@nokia.com>
References: <1300035271-8138-1-git-send-email-jslaby@suse.cz> <1300035271-8138-2-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gregkh-l3A5Bk7waGM@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ext Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1300035271-8138-2-git-send-email-jslaby-AlSwsSmVLrQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 13 March 2011 18:54:31 ext Jiri Slaby, you wrote:
> Currently, for N 5800 XM I get:
> cdc_phonet: probe of 1-6:1.10 failed with error -22
>=20
> It's because phonet_header is empty. Extra altsetting looks like
> there:
> E 05 24 00 01 10 03 24 ab 05 24 06 0a 0b 04 24 fd  .$....$..$....$.
> E 00                                               .
>=20
> I don't see the header used anywhere so just check if the phonet
> descriptor is there, not the structure itself.
>=20
> Signed-off-by: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
> Cc: R=C3=A9mi Denis-Courmont <remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

Acked-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
