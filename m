From: David Miller <davem@davemloft.net>
Subject: Re: Multicast snooping fixes and suggestions
Date: Tue, 22 Feb 2011 10:08:06 -0800 (PST)
Message-ID: <20110222.100806.71122067.davem@davemloft.net>
References: <1297811961-19249-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au
To: linus.luessing@web.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1297811961-19249-1-git-send-email-linus.luessing@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Linus L=FCssing <linus.luessing@web.de>
Date: Wed, 16 Feb 2011 00:19:16 +0100

> While testing the (very awesome!) bridge igmp/mld snooping support I =
came across
> two issues which are breaking IPv6 multicast snooping and IPv6
> non-link-local multicast on bridges with multicast snooping support e=
nabled
> in general. The first two patches shall fix these issues.
>=20
> The third one addresses a potential bug on little endian machines whi=
ch I noticed
> during this little code reviewing. This patch is untested though, fee=
dback welcome.
>=20
> The fourth and fifth patch are a suggestion to also permit using the =
bridge multicast
> snooping feature for link local multimedia multicast traffic. Therefo=
re
> using the transient multicast flag instead of the non-link-local scop=
e criteria
> seems to be a suitable solution at least for IPv6, in my opinion. Let=
 me know what
> you think about it.
>=20
> Thanks for reviewing these patches.

Nice work, all applied to net-2.6, thanks!
