From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 02/11] soc/fsl: Introduce DPAA BMan device management
 driver
Date: Fri, 10 Jul 2015 13:50:27 -0500
Message-ID: <1436554227.2658.161.camel@freescale.com>
References: <1436473322-21247-1-git-send-email-Roy.Pledge@freescale.com>
	 <1436473322-21247-3-git-send-email-Roy.Pledge@freescale.com>
	 <1436517510.20619.123.camel@tiscali.nl>
	 <1436549503.2658.157.camel@freescale.com>
	 <BN3PR0301MB1267E9EFD8CBC294275028B68C9F0@BN3PR0301MB1267.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Bolle <pebolle@tiscali.nl>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Pledge Roy-R01356 <roy.pledge@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BN3PR0301MB1267E9EFD8CBC294275028B68C9F0@BN3PR0301MB1267.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-07-10 at 13:29 -0500, Pledge Roy-R01356 wrote:
> >   return in_be32((void *)bm + offset);
> > >          ^
> > > [...]/drivers/soc/fsl/qbman/bman.c: In function =E2=80=98__bm_out=
=E2=80=99:
> > > [...]/drivers/soc/fsl/qbman/bman.c:172:2: error: implicit declara=
tion
> > > of function =E2=80=98out_be32=E2=80=99 [-Werror=3Dimplicit-functi=
on-declaration]
> > >   out_be32((void *)bm + offset, val);
> >=20
> > These PPCisms will need to be fixed.  LS1043A is an ARM chip with D=
PAA=20
> > 1.0.
>=20
> LS1043 (ARM, Little Endian) support is still work in progress.  The p=
atches=20
> for that are being tested now but are based on the SDK version of the=
=20
> driver and will need to be massaged in order to get them applied here=
=2E  Our=20
> plan of record is to add upstream support for this at a later time.

If you're already reworking this for upstream acceptance, why not fix t=
he=20
more obvious PPCisms now?

-Scott
