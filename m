From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: bnx2x: convert to hw_features
Date: Tue, 12 Apr 2011 14:52:53 -0700 (PDT)
Message-ID: <20110412.145253.28813257.davem@davemloft.net>
References: <20110412140708.GA21835@rere.qmqm.pl>
	<1302619012.6750.8.camel@lb-tlvb-vladz>
	<20110412193823.0823213A65@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, vladz@broadcom.com, eilong@broadcom.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46629
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932097Ab1DLVx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 17:53:28 -0400
In-Reply-To: <20110412193823.0823213A65@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 12 Apr 2011 21:38:23 +0200 (CEST)

> Since ndo_fix_features callback is postponing features change when
> bp->recovery_state !=3D BNX2X_RECOVERY_DONE, netdev_update_features()
> has to be called again when this condition changes. Previously,
> ethtool_ops->set_flags callback returned -EBUSY in that case
> (it's not possible in the new model).
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
>=20
> v5: - don't delay set_features, as it's rtnl_locked - same as recover=
y process
> v4: - complete bp->rx_csum -> NETIF_F_RXCSUM conversion
>     - add check for failed ndo_set_features in ndo_open callback
> v3: - include NETIF_F_LRO in hw_features
>     - don't call netdev_update_features() if bnx2x_nic_load() failed
> v2: - comment in ndo_fix_features callback

I've applied this.

=46rom what I can tell the is basic agreement from the Broadcom folks,
and if any fixups are needed that can be done with follow-up
patches.

Thanks.
