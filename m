From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH V2] tipc: Use bsearch library function
Date: Tue, 19 Sep 2017 01:08:33 +0000
Message-ID: <DB5PR0701MB1958240FB878DD084D0BA4C49A600@DB5PR0701MB1958.eurprd07.prod.outlook.com>
References: <20170911.143025.555018840006192902.davem@davemloft.net>
         <20170916075036.28676-1-thomas@m3y3r.de>
         <16128f5e-66ff-b6ec-c0e1-74ea08c212b0@windriver.com>
         <1505553970.16316.1.camel@perches.com>
         <64ee51ce-eb7e-ac1c-56a9-9481f6f80b35@windriver.com>
         <1505555908.16316.5.camel@perches.com>
         <35f41984-22e9-5adc-0e4d-a4ef4204f6d7@windriver.com>
         <1505557061.16316.7.camel@perches.com>
         <DB5PR0701MB1958558286B3B455C601754A9A6D0@DB5PR0701MB1958.eurprd07.prod.outlook.com>
         <760F46A5-2C04-4F3F-83C5-5EA331CFA1D6@m3y3r.de>
         <DB5PR0701MB195892D3D60DAB5D7C1109AE9A620@DB5PR0701MB1958.eurprd07.prod.outlook.com>
 <1505682926.16316.15.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Ying Xue <ying.xue@windriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "tipc-discussion@lists.sourceforge.net"
        <tipc-discussion@lists.sourceforge.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>, Thomas Meyer <thomas@m3y3r.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505682926.16316.15.camel@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Joe Perches
> Sent: Sunday, September 17, 2017 23:15
> To: Jon Maloy <jon.maloy@ericsson.com>; Thomas Meyer
> <thomas@m3y3r.de>
> Cc: Ying Xue <ying.xue@windriver.com>; netdev@vger.kernel.org; tipc-
> discussion@lists.sourceforge.net; linux-kernel@vger.kernel.org;
> davem@davemloft.net
> Subject: Re: [PATCH V2] tipc: Use bsearch library function
>=20
> On Sun, 2017-09-17 at 16:27 +0000, Jon Maloy wrote:
> > > -----Original Message-----
> > > From: Thomas Meyer [mailto:thomas@m3y3r.de]
> []
> > > What about the other binary search implementation in the same file?
> > > Should I try to convert it it will it get NAKed for performance reaso=
ns too?
> >
> > The searches for inserting and removing publications is less time
> > critical, so that would be ok with me.
> > If you have any more general interest in improving the code in this
> > file (which is needed) it would also be appreciated.
>=20
> Perhaps using an rbtree would be an improvement.

Not a bad idea. It would probably reduce the code amount, possibly at the e=
xpense of cache hit rate during the binary lookup.
It is worth looking into.

///jon
