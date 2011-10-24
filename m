From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix ipsec forward performance regression
Date: Mon, 24 Oct 2011 03:02:03 -0400 (EDT)
Message-ID: <20111024.030203.404195331212003955.davem@davemloft.net>
References: <4EA3C91C.3090801@intel.com>
	<1319360590.6180.75.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zheng.z.yan@intel.com, netdev@vger.kernel.org,
	kim.phillips@freescale.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297Ab1JXHCI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 03:02:08 -0400
In-Reply-To: <1319360590.6180.75.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 23 Oct 2011 11:03:10 +0200

> Le dimanche 23 octobre 2011 =E0 15:58 +0800, Yan, Zheng a =E9crit :
>> There is bug in commit 5e2b61f(ipv4: Remove flowi from struct rtable=
).
>> It makes xfrm4_fill_dst() modify wrong data structure.
>>=20
>> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
 ...
> Reported-by: Kim Phillips <kim.phillips@freescale.com>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
