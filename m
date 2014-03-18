From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net,stable] net: cdc_ncm: fix control message ordering
Date: Tue, 18 Mar 2014 15:58:42 -0400 (EDT)
Message-ID: <20140318.155842.1610081544107118579.davem@davemloft.net>
References: <1395069918-18585-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, pasik-X3B1VOXEql0@public.gmane.org,
	tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1395069918-18585-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Mon, 17 Mar 2014 16:25:18 +0100

> This is a context modified revert of commit 6a9612e2cb22
> ("net: cdc_ncm: remove ncm_parm field") which introduced
> a NCM specification violation, causing setup errors for
> some devices. These errors resulted in the device and
> host disagreeing about shared settings, with complete
> failure to communicate as the end result.
>=20
> The NCM specification require that many of the NCM specific
> control reuests are sent only while the NCM Data Interface
> is in alternate setting 0. Reverting the commit ensures that
> we follow this requirement.
>=20
> Fixes: 6a9612e2cb22 ("net: cdc_ncm: remove ncm_parm field")
> Reported-and-tested-by: Pasi K=E4rkk=E4inen <pasik-X3B1VOXEql0@public.gmane.org>
> Reported-by: Thomas Sch=E4fer <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> ---
> This needs to go to v3.14 and v3.13.x stable. The bug was introduced
> in v3.13.

Applied and queued up for -stable, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
