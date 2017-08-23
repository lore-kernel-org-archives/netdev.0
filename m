From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH v2 1/6] fsl/fman: enable FMan Keygen
Date: Wed, 23 Aug 2017 05:16:52 +0000
Message-ID: <AM5PR0402MB26915EFC135F6ECEBA92C89DEC850@AM5PR0402MB2691.eurprd04.prod.outlook.com>
References: <1503423066-15420-2-git-send-email-madalin.bucur@nxp.com>
        <20170822.143510.1048652578169181274.davem@davemloft.net>
        <AM5PR0402MB2691CF2AC9555829EC89C59CEC850@AM5PR0402MB2691.eurprd04.prod.outlook.com>
 <20170822.214645.953115103494976385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Florinel Iordache" <florinel.iordache@nxp.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170822.214645.953115103494976385.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, August 23, 2017 7:47 AM
> To: Madalin-cristian Bucur <madalin.bucur@nxp.com>
> Cc: netdev@vger.kernel.org; linuxppc-dev@lists.ozlabs.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH v2 1/6] fsl/fman: enable FMan Keygen
>=20
> From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
> Date: Wed, 23 Aug 2017 04:36:56 +0000
>=20
> > The struct fman is only visible in the fman file, the fman port
> > module uses struct fman as an opaque pointer, thus this export.
>=20
> Don't use that programming model.
>=20
> Export the datastructure properly to it's users.
>=20
> This abstraction scheme is so wasteful and costly.

Normally does not come with this cost, it's this case where one of the
sub-modules needs to call into another that gets things complicated.
I'll move struct fman to the header file.

Thanks,
Madalin
