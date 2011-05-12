From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: group FCoE related feature flags
Date: Thu, 12 May 2011 14:55:30 -0700 (PDT)
Message-ID: <20110512.145530.71112637.davem@davemloft.net>
References: <20110509215133.4346.14504.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, mirq-linux@rere.qmqm.pl,
	jeffrey.t.kirsher@intel.com, devel@open-fcoe.org
To: yi.zou@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47894
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757985Ab1ELV4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 17:56:02 -0400
In-Reply-To: <20110509215133.4346.14504.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Yi Zou <yi.zou@intel.com>
Date: Mon, 09 May 2011 14:53:27 -0700

> Micha=A9=A9 Miros=A9=A9aw's patch (http://patchwork.ozlabs.org/patch/=
94421/) fixes the
> issue (http://patchwork.ozlabs.org/patch/94188/) about not populating=
 FCoE related
> flags correctly on vlan devices. However, only NETIF_F_FCOE_CRC is pa=
rt of the
> NETIF_F_ALL_TX_OFFLOADS right now, where weed NETIF_F_FCOE_MTU and NE=
TIF_F_FSO
> as well.
>=20
> Therefore, add NETIF_F_ALL_FCOE to indicate feature flags used by FCo=
E TX offloads.
> These include NETIF_F_FCOE_CRC, NETIF_F_FCOE_MTU, and NETIF_F_FSO and=
 add them to
> be part of NETIF_F_ALL_TX_OFFLOADS. This would eventually make sure a=
ll FCoE needed
> flags are populated properly to vlan devices.
>=20
> Signed-off-by: Yi Zou <yi.zou@intel.com>

Applied.
