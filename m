From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] f_phonet: avoid pskb_pull(), fix OOPS with CONFIG_HIGHMEM
Date: Tue, 1 Mar 2011 09:34:30 +0200
Message-ID: <201103010934.30730.remi.denis-courmont@nokia.com>
References: <linux-usb@vger.kernel.org> <1298465493-3787-1-git-send-email-remi.denis-courmont@nokia.com> <20110228.123844.70195701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110228.123844.70195701.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 28 February 2011 22:38:44 ext David Miller, you wrote:
> From: R=E9mi Denis-Courmont <remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
> Date: Wed, 23 Feb 2011 14:51:33 +0200
>=20
> > This is similar to what we already do in cdc-phonet.c in the same
> > situation. pskb_pull() refuses to work with HIGHMEM, even if it is
> > known that the socket buffer is entirely in "low" memory.
> >=20
> > Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org=
>
>=20
> Applied, thanks.

Hmm, this is already somewhere in linux-usb, from what I understood (I =
suppose=20
git-merge does not care much).

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
