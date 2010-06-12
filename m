From: David Miller <davem@davemloft.net>
Subject: Re: mpd client timeouts (bisected) 2.6.35-rc3
Date: Sat, 12 Jun 2010 14:58:35 -0700 (PDT)
Message-ID: <20100612.145835.123986343.davem@davemloft.net>
References: <20100612102802.GA1782@arch.tripp.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.r.fastabend@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: markus@trippelsdorf.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100612102802.GA1782@arch.tripp.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Markus Trippelsdorf <markus@trippelsdorf.de>
Date: Sat, 12 Jun 2010 12:28:02 +0200

> Commit 597a264b1a9c7e36d1728f677c66c5c1f7e3b837:
> =BBnet: deliver skbs on inactive slaves to exact matches=AB
>=20
> causes large timeouts when mpd clients try to connect to a locally
> running mpd (music player demon) on my machine. This makes it=20
> impossible to control mpd.
>=20
> I bisected this down to the commit mentioned above.
> Reverting the commit from 2.6.35-rc3 also solves the problem.

John, find an easy and fast way to fix this or else I am
going to revert.

Thanks.
