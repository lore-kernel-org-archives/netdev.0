From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: enable GRO by default for vlan devices
Date: Thu, 16 Sep 2010 00:03:23 +0200
Message-ID: <1284588203.2462.81.camel@edumazet-laptop>
References: <20100914.213544.112598547.davem@davemloft.net>
	 <20100915163749.GA4191@mmm.home.ifup.org>
	 <1284570520.2462.5.camel@edumazet-laptop>
	 <20100915.101418.59680213.davem@davemloft.net>
	 <1284571476.2293.5.camel@achroite.uk.solarflarecom.com>
	 <20100915192424.GE4191@mmm.home.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	donald.c.skidmore@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Brandon Philips <bphilips@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50564 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727Ab0IOWD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 18:03:29 -0400
Received: by wyf22 with SMTP id 22so732321wyf.19
        for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 15:03:28 -0700 (PDT)
In-Reply-To: <20100915192424.GE4191@mmm.home.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 septembre 2010 =C3=A0 12:24 -0700, Brandon Philips a =C3=
=A9crit :
> Currently vlan devices don't have GRO by default as none of the Ether=
net
> drivers add NETIF_F_GRO to their vlan_features.
>=20
> As GRO is a software feature add GRO to dev->vlan_features in
> register_netdevice() and let vlan_dev_init() take care that it gets
> enabled only when dev->features has NETIF_F_GRO too.
>=20
> Signed-off-by: Brandon Philips <bphilips@suse.de>
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


