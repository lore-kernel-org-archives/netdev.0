From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression, bisected: WARNING spam with ipsec since 2.6.35
Date: Fri, 17 Sep 2010 17:03:30 +0200
Message-ID: <1284735810.3391.85.camel@edumazet-laptop>
References: <20100916213138.GA6605@elliptictech.com>
	 <1284676070.4784.25.camel@edumazet-laptop>
	 <20100917141920.GA9280@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100917141920.GA9280@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 17 septembre 2010 =C3=A0 10:19 -0400, Nick Bowler a =C3=A9c=
rit :
> On 2010-09-17 00:27 +0200, Eric Dumazet wrote:
> > I suspect following patch is needed, before further changes.
> >=20
> > [PATCH] xfrm: dont assume rcu_read_lock in xfrm_output_one()
>=20
> Yup, that makes the warnings go away.  Thanks.
>=20

Thanks for testing.
