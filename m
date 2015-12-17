From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH] net/macb: add proper header file
Date: Thu, 17 Dec 2015 19:40:41 +0530
Message-ID: <20151217141041.GA726@sudip-pc>
References: <1450354553-18745-1-git-send-email-sudipm.mukherjee@gmail.com>
 <87twnhs0vc.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35167 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964929AbbLQOKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 09:10:51 -0500
Content-Disposition: inline
In-Reply-To: <87twnhs0vc.fsf@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2015 at 01:41:59PM +0100, Gregory CLEMENT wrote:
> Hi Sudip,
> =20
>  On jeu., d=E9c. 17 2015, Sudip Mukherjee <sudipm.mukherjee@gmail.com=
> wrote:
>=20
> > mips allmodconfig build fails with the error:
> >
> > drivers/net/ethernet/cadence/macb.c: In function 'macb_probe':
> > drivers/net/ethernet/cadence/macb.c:2908:2: error: implicit declara=
tion of function 'devm_gpiod_get_optional' [-Werror=3Dimplicit-function=
-declaration]
> >   bp->reset_gpio =3D devm_gpiod_get_optional(&bp->pdev->dev, "phy-r=
eset",
> >   ^
> > drivers/net/ethernet/cadence/macb.c:2909:8: error: 'GPIOD_OUT_HIGH'=
 undeclared (first use in this function)
> >         GPIOD_OUT_HIGH);
> >         ^
> > drivers/net/ethernet/cadence/macb.c:2909:8: note: each undeclared i=
dentifier is reported only once for each function it appears in
> > drivers/net/ethernet/cadence/macb.c: In function 'macb_remove':
> > drivers/net/ethernet/cadence/macb.c:2979:3: error: implicit declara=
tion of function 'gpiod_set_value' [-Werror=3Dimplicit-function-declara=
tion]
> >    gpiod_set_value(bp->reset_gpio, 0);
> >    ^
> >
> > Add the proper header file to resolve it. =20
>=20
>=20
> A proper fix already has been posted along with the proper device tre=
e
> bindinsg too:
> http://marc.info/?l=3Dlinux-netdev&m=3D145034590619620&w=3D2

Thanks, just compiled with it and the build error for which I posted th=
is patch
is now gone.

regards
sudip
