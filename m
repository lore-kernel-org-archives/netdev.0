From: Andres Salomon <dilinger@queued.net>
Subject: Re: [PATCH] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 13 Jan 2011 08:29:50 -0800
Message-ID: <20110113082950.6747ebb8@queued.net>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
	<1294928559.3570.130.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294928559.3570.130.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Jan 2011 15:22:39 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 13 janvier 2011 =C3=A0 19:49 +0800, Po-Yu Chuang a =C3=A9cri=
t :
> > From: Po-Yu Chuang <ratbert@faraday-tech.com>
> >=20
> > FTMAC100 Ethernet Media Access Controller supports 10/100 Mbps and
> > MII.  This driver has been working on some ARM/NDS32 SoC including
> > Faraday A320 and Andes AG101.
> >=20
> > Signed-off-by: Po-Yu Chuang <ratbert@faraday-tech.com>
> > ---
> >  drivers/net/Kconfig    |    9 +
> >  drivers/net/Makefile   |    1 +
> >  drivers/net/ftmac100.c | 1341
> > ++++++++++++++++++++++++++++++++++++++++++++++++
> > drivers/net/ftmac100.h |  180 +++++++ 4 files changed, 1531
> > insertions(+), 0 deletions(-) create mode 100644
> > drivers/net/ftmac100.c create mode 100644 drivers/net/ftmac100.h
>=20
> Hi
>=20
[...]
>=20
> 9) Instead of dev_info(&netdev->dev ...) , please consider
> netdev_info()
>=20
>=20

No one else mentioned it, so I'll add:

Don't explicitly inline functions unless they're in a header, or you
have a really good reason (and that reason should probably be described
in a comment).  Otherwise, just leave off the 'inline' keyword; the
compiler is smart enough to decide whether a function should be inlined
or not.
