From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] bcm43xx-softmac: Init, shutdown and restart fixes
Date: Mon, 11 Sep 2006 14:29:02 -0400
Message-ID: <20060911182857.GA19326@tuxdriver.com>
References: <44E9C6A0.3090107@lwfinger.net> <200608211653.01997.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:32266 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932305AbWIKSak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2006 14:30:40 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200608211653.01997.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2006 at 04:52:58PM +0200, Michael Buesch wrote:
> On Monday 21 August 2006 16:43, Larry Finger wrote:

> > @@ -3537,11 +3536,10 @@ static int bcm43xx_init_board(struct bcm
> > =A0=A0=A0=A0=A0=A0=A0=A0err =3D bcm43xx_select_wireless_core(bcm, -=
1);
> > =A0=A0=A0=A0=A0=A0=A0=A0if (err)
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0goto err_crystal_of=
f;
> > -
> > -=A0=A0=A0=A0=A0=A0=A0bcm43xx_periodic_tasks_setup(bcm);
> > =A0=A0=A0=A0=A0=A0=A0=A0err =3D bcm43xx_sysfs_register(bcm);
> > =A0=A0=A0=A0=A0=A0=A0=A0if (err)
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0goto err_wlshutdown=
;
> > +=A0=A0=A0=A0=A0=A0=A0bcm43xx_periodic_tasks_setup(bcm);
> > =A0=A0=A0=A0=A0=A0=A0=A0err =3D bcm43xx_rng_init(bcm);
> > =A0=A0=A0=A0=A0=A0=A0=A0if (err)
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0goto err_sysfs_unre=
g;
>=20
> Either move bcm43xx_periodic_tasks_setup after rng_init, or
> delete the periodic work again, if rng_init fails.

Larry, will you be posting another patch to account for these comments?

John
--=20
John W. Linville
linville@tuxdriver.com
