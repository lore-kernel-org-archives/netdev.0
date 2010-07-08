From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vlan: allow TSO setting on vlan interfaces
Date: Thu, 08 Jul 2010 08:46:27 +0200
Message-ID: <1278571587.2543.9.camel@edumazet-laptop>
References: <1278522874.5906.9.camel@edumazet-laptop>
	 <1278523511.2080.3.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35782 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225Ab0GHGqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 02:46:35 -0400
Received: by wyf23 with SMTP id 23so278226wyf.19
        for <netdev@vger.kernel.org>; Wed, 07 Jul 2010 23:46:34 -0700 (PDT)
In-Reply-To: <1278523511.2080.3.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 07 juillet 2010 =C3=A0 18:25 +0100, Ben Hutchings a =C3=A9c=
rit :
> On Wed, 2010-07-07 at 19:14 +0200, Eric Dumazet wrote:
> > When we need to shape traffic with low speeds, we need to disable t=
so on
> > network interface :
> >=20
> > ethtool -K eth0.2240 tso off
> >=20
> > It seems vlan interfaces miss the set_tso() ethtool method.
> > Propagating tso changes from lower device is not always wanted, som=
e
> > vlan want TSO on, other want TSO off.
>=20
> But it should not be possible to enable TSO if the underlying device
> doesn't support it.

Yes indeed, I'll provide a more generic patch, thanks !


