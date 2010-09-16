From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: enable GRO by default for vlan devices
Date: Wed, 15 Sep 2010 22:32:40 -0700 (PDT)
Message-ID: <20100915.223240.216746981.davem@davemloft.net>
References: <1284571476.2293.5.camel@achroite.uk.solarflarecom.com>
	<20100915192424.GE4191@mmm.home.ifup.org>
	<1284588203.2462.81.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bphilips@suse.de, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	donald.c.skidmore@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42223
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752159Ab0IPFcW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Sep 2010 01:32:22 -0400
In-Reply-To: <1284588203.2462.81.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Sep 2010 00:03:23 +0200

> Le mercredi 15 septembre 2010 =E0 12:24 -0700, Brandon Philips a =E9c=
rit :
>> Currently vlan devices don't have GRO by default as none of the Ethe=
rnet
>> drivers add NETIF_F_GRO to their vlan_features.
>>=20
>> As GRO is a software feature add GRO to dev->vlan_features in
>> register_netdevice() and let vlan_dev_init() take care that it gets
>> enabled only when dev->features has NETIF_F_GRO too.
>>=20
>> Signed-off-by: Brandon Philips <bphilips@suse.de>
>>=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
