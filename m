From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v5 2/8] dpaa_eth: add support for DPAA Ethernet
Date: Fri, 04 Dec 2015 15:08:17 -0500 (EST)
Message-ID: <20151204.150817.532736454345962933.davem@davemloft.net>
References: <1449150589-26253-3-git-send-email-madalin.bucur@freescale.com>
	<20151204.145549.859527220803940077.davem@davemloft.net>
	<1449259235.8611.19.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: madalin.bucur@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	scottwood@freescale.com, igal.liberman@freescale.com,
	ppc@mindchasers.com, pebolle@tiscali.nl,
	joakim.tjernlund@transmode.se, gregkh@linuxfoundation.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449259235.8611.19.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Joe Perches <joe@perches.com>
Date: Fri, 04 Dec 2015 12:00:35 -0800

> On Fri, 2015-12-04 at 14:55 -0500, David Miller wrote:
>> From: Madalin Bucur <madalin.bucur@freescale.com>
>> Date: Thu, 3 Dec 2015 15:49:43 +0200
>>=20
>> > @@ -0,0 +1,22 @@
>> > +menuconfig FSL_DPAA_ETH
>> > +=A0=A0=A0=A0=A0tristate "DPAA Ethernet"
>> > +=A0=A0=A0=A0=A0depends on FSL_SOC && FSL_BMAN && FSL_QMAN && FSL_=
=46MAN
>> > +=A0=A0=A0=A0=A0select PHYLIB
>> > +=A0=A0=A0=A0=A0select FSL_FMAN_MAC
>>=20
>> I do not see the FSL_FMAN_MAC Kconfig symbol defined anywhere in the
>> tree.
>=20
> I believe this patch series is dependent on two
> other patch series mentioned in the cover letter.

Then this shouldn't have been submitted.

The dependent series has been through a lot of changes and still needs
lots of work, and is very far from being applied.

Posting patches depending upon it is therefore wholly inapproprate.
That time and effort should be spent putting the dependent series
into proper shape.

Since I see what is happening here, I am going to simply ignore all
future submissions of dpaa_eth, until the dependencies are worked
out properly so don't bother posting this stuff again until that
happens.

Thanks.
