From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] e1000/e1000e/igb/ixgb/ixgbe: set
 NETIF_F_HIGHDMA for VLAN feature flags
Date: Wed, 22 Sep 2010 23:00:14 -0700 (PDT)
Message-ID: <20100922.230014.57465311.davem@davemloft.net>
References: <20100923035755.11561.14170.stgit@localhost.localdomain>
	<20100922.212023.91330415.davem@davemloft.net>
	<1285219690.2380.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, yi.zou@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37886
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751981Ab0IWF7z convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 01:59:55 -0400
In-Reply-To: <1285219690.2380.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Sep 2010 07:28:10 +0200

> Le mercredi 22 septembre 2010 =E0 21:20 -0700, David Miller a =E9crit=
 :
>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Date: Wed, 22 Sep 2010 20:57:58 -0700
>>=20
>> > From: Yi Zou <yi.zou@intel.com>
>> >=20
>> > If the netdev->features is set with NETIF_F_HIGHDMA, we should set=
 the
>> > corresponding netdev->vlan_features as well to allow VLAN netdev c=
reated
>> > on top of the real netdev to be able to also benefit from HIGHDMA =
on 32bit
>> > system, reducing the performance hit that is caused by __skb_linea=
rize(),
>> > particularly for large send. This is fixed in this patch for all I=
ntel e1000,
>> > e1000e, igb, ixgbe, and ixgbe drivers since this should be benefic=
ial
>> > to all devices supported by these drivers.
>> >=20
>> > Signed-off-by: Yi Zou <yi.zou@intel.com>
>> > Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
>> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>=20
>> Applied.
>=20
> Maybe this could be done in core network.

Indeeed, just as we do for NETIF_F_GRO now.
