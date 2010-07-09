From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 001/001] QoS and/or fair queueing: Stateless NAT BUG
Date: Fri, 09 Jul 2010 10:52:53 -0700 (PDT)
Message-ID: <20100709.105253.71108558.davem@davemloft.net>
References: <201007091937.17349.rpartearroyo@albentia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, ipichel@albentia.com,
	nmoron@albentia.com, netdev@vger.kernel.org
To: rpartearroyo@albentia.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201007091937.17349.rpartearroyo@albentia.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Rodrigo Partearroyo Gonz=E1lez <rpartearroyo@albentia.com>
Date: Fri, 9 Jul 2010 19:37:16 +0200

> Hi all,
> I have been testing Stateless NAT and found that ICMP packets with le=
ngth
> less than 20 bytes were not correctly NAT'ed. I have found a BUG that
> makes taking into account IP header length twice, so ICMP packets sma=
ller
> than 20 bytes were being dropped.
>=20
> Proposed formal patch is below, as suggested by Eric Dumazet, thanks.
> It is taken from 2.6.34.1 stable version.
>=20
> Signed-off-by: Rodrigo Partearroyo Gonz=E1lez <rpartearroyo@albentia.=
com>

Applied, thanks.
