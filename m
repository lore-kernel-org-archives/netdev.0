From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] sunrpc: prompt for RPCSEC_GSS_KRB5 even if NFS_V4 is
 enabled
Date: Mon, 27 Sep 2010 07:39:32 -0400
Message-ID: <1285587572.19362.2.camel@heimdal.trondhjem.org>
References: <20100909181454.GB14915@pengutronix.de>
	 <1285584120-16860-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1285584120-16860-1-git-send-email-u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-09-27 at 12:41 +0200, Uwe Kleine-K=C3=B6nig wrote:
> NFS_V4 works fine without RPCSEC_GSS_KRB5 (even without CRYPTO).
> This dependency was introduced in
>=20
> 	df486a2 (NFS: Fix the selection of security flavours in Kconfig)
>=20
> to fix a build failure as RPCSEC_GSS_KRB5 was thought to be needed fo=
r
> NFS_V4.  The fix didn't work completely as NFS_V4 didn't enforce CRYP=
TO
> and so the select on RPCSEC_GSS_KRB5 didn't work in all situations (e=
=2Eg.
> arm/mx1_defconfig).
>=20
> This was rectified by
>=20
> 	827e345 (SUNRPC: Fix the NFSv4 and RPCSEC_GSS Kconfig dependencies)
>=20
> but the magic for RPCSEC_GSS_KRB5 introduced by df486a2 wasn't revert=
ed.
>=20
> Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> ---
> Hello,
>=20
> after Trond sent me the patch that later ended in 827e345702 I sugges=
ted
> to fold the patch below into it[1], but without reaction and success =
as I
> noticed just now. :-(
>=20
> Best regards
> Uwe

That's because you completely fail to justify why should we change the
behaviour to suddenly make RPCSEC_GSS_KRB5 optional for NFSv4. That has
never been the case before.

Trond
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
