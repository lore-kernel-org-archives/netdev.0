From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH v2 1/6] fsl/fman: enable FMan Keygen
Date: Wed, 23 Aug 2017 04:36:56 +0000
Message-ID: <AM5PR0402MB2691CF2AC9555829EC89C59CEC850@AM5PR0402MB2691.eurprd04.prod.outlook.com>
References: <1503423066-15420-1-git-send-email-madalin.bucur@nxp.com>
        <1503423066-15420-2-git-send-email-madalin.bucur@nxp.com>
 <20170822.143510.1048652578169181274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170822.143510.1048652578169181274.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of David Miller
> Sent: Wednesday, August 23, 2017 12:35 AM
> Subject: Re: [PATCH v2 1/6] fsl/fman: enable FMan Keygen
>=20
> From: Madalin Bucur <madalin.bucur@nxp.com>
> Date: Tue, 22 Aug 2017 20:31:01 +0300
>=20
> >  /**
> > + * fman_get_keygen
> > + *
> > + * @fman:	A Pointer to FMan device
> > + *
> > + * Get the handle to KeyGen module part of FM driver
> > + *
> > + * Return: Handle to KeyGen
> > + */
> > +struct fman_keygen *fman_get_keygen(struct fman *fman)
> > +{
> > +	return fman->keygen;
> > +}
> > +EXPORT_SYMBOL(fman_get_keygen);
>=20
> Please don't do this.
>=20
> Just directly derefence the pointer in the source code to
> get the keygen.
>=20
> Thank you.

Hi,

The struct fman is only visible in the fman file, the fman port module uses=
 struct
fman as an opaque pointer, thus this export.

Madalin
