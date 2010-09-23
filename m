From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH] e1000/e1000e/igb/ixgb/ixgbe: set
 NETIF_F_HIGHDMA for VLAN feature flags
Date: Thu, 23 Sep 2010 07:28:10 +0200
Message-ID: <1285219690.2380.70.camel@edumazet-laptop>
References: <20100923035755.11561.14170.stgit@localhost.localdomain>
	 <20100922.212023.91330415.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, yi.zou@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36192 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702Ab0IWF2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 01:28:17 -0400
Received: by fxm12 with SMTP id 12so554681fxm.19
        for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 22:28:15 -0700 (PDT)
In-Reply-To: <20100922.212023.91330415.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 septembre 2010 =C3=A0 21:20 -0700, David Miller a =C3=A9=
crit :
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 22 Sep 2010 20:57:58 -0700
>=20
> > From: Yi Zou <yi.zou@intel.com>
> >=20
> > If the netdev->features is set with NETIF_F_HIGHDMA, we should set =
the
> > corresponding netdev->vlan_features as well to allow VLAN netdev cr=
eated
> > on top of the real netdev to be able to also benefit from HIGHDMA o=
n 32bit
> > system, reducing the performance hit that is caused by __skb_linear=
ize(),
> > particularly for large send. This is fixed in this patch for all In=
tel e1000,
> > e1000e, igb, ixgbe, and ixgbe drivers since this should be benefici=
al
> > to all devices supported by these drivers.
> >=20
> > Signed-off-by: Yi Zou <yi.zou@intel.com>
> > Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> Applied.


Maybe this could be done in core network.



