From: "Chickles, Derek" <Derek.Chickles@cavium.com>
Subject: RE: [PATCH] liquidio: stop using huge static buffer, save 4096k in
 .data
Date: Tue, 20 Jun 2017 20:15:34 +0000
Message-ID: <MWHPR07MB29434F09FBC054D2E0310D6FF3C50@MWHPR07MB2943.namprd07.prod.outlook.com>
References: <20170619195052.13176-1-dvlasenk@redhat.com>
 <20170620.152142.1443468587541525646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Manlunas, Felix" <Felix.Manlunas@cavium.com>,
        "Kanneganti, Prasad" <Prasad.Kanneganti@cavium.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        "dvlasenk@redhat.com" <dvlasenk@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170620.152142.1443468587541525646.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, June 20, 2017 12:22 PM
>=20
> From: Denys Vlasenko <dvlasenk@redhat.com>
> Date: Mon, 19 Jun 2017 21:50:52 +0200
>=20
> > Only compile-tested - I don't have the hardware.
> >
> > From code inspection, octeon_pci_write_core_mem() appears to be safe wr=
t
> > unaligned source. In any case, u8 fbuf[] was not guaranteed to be align=
ed
> > anyway.
> >
> > Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
>=20
> Looks good to me but I'll let one of the liquidio guys review this first
> before I apply it.

Felix is going to try this out this week to confirm. Let's wait for his ack=
.
