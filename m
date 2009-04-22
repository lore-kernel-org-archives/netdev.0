From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 1/2] Add an alternative cs89x0 driver
Date: Wed, 22 Apr 2009 14:18:21 +0200
Message-ID: <20090422121821.GI21747@pengutronix.de>
References: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de> <1240387172-21818-2-git-send-email-s.hauer@pengutronix.de> <ba216b430904220228o369d0a5eg79c876733dcc7c8c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Lennert Buytenhek <kernel@wantstofly.org>,
	Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
To: Ivo Clarysse <ivo.clarysse@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:45062 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010AbZDVMSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 08:18:23 -0400
Content-Disposition: inline
In-Reply-To: <ba216b430904220228o369d0a5eg79c876733dcc7c8c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2009 at 11:28:17AM +0200, Ivo Clarysse wrote:
> On Wed, Apr 22, 2009 at 9:59 AM, Sascha Hauer <s.hauer@pengutronix.de=
> wrote:
>=20
> > +#define CS8900A =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x0=
000
> > +#define REV_B =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A07
> > +#define REV_C =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A08
> > +#define REV_D =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A09
>=20
> These REV_B / REV_C / REV_D defines are not used, and in fact depend
> on the cs89x0x variant.
>=20
> > + =A0 =A0 =A0 dev_info(&pdev->dev, "CS8900A rev %c detected\n",
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 'B' + REVISION(value)=
 - REV_B);
>=20
> This will report incorrectly for CS8900 (not CS8900A),  and for CS890=
0A rev. F:

Ok, will fix.

Sascha

--=20
Pengutronix e.K.                           |                           =
  |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0  =
  |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-555=
5 |
