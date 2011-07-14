From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net] net: fix bonding advertising offloads it can't
 support
Date: Thu, 14 Jul 2011 15:37:53 -0700 (PDT)
Message-ID: <20110714.153753.1058384459929570771.davem@davemloft.net>
References: <20110714.145857.1611970250010658023.davem@davemloft.net>
	<45ec1e78b1bf8934a84e68968a0bb8b747eec6bf.1310682766.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	kaber@trash.net
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45125 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932279Ab1GNWkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 18:40:05 -0400
In-Reply-To: <45ec1e78b1bf8934a84e68968a0bb8b747eec6bf.1310682766.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Fri, 15 Jul 2011 00:34:50 +0200 (CEST)

> There is no software fallback implemented for SCTP or FCoE checksummi=
ng,
> and so it should not be passed on by software devices like bridge or
> bonding.
>=20
> For VLAN devices, this is different. First, the driver for underlying
> device should be prepared to get offloaded packets even when the feat=
ure
> is disabled (especially if it advertises it in vlan_features). Second=
,
> devices under VLANs do not get replaced without tearing down the VLAN
> first.
>=20
> This fixes a mess I accidentally introduced while converting bonding =
to
> ndo_fix_features in b2a103e6d0.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

I already applied this, and the SCTP patch, to net-2.6
