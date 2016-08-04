From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net 0/3] mlxsw: DCB fixes
Date: Thu, 4 Aug 2016 17:36:19 +0300
Message-ID: <1470321382-10426-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <jiri@mellanox.com>,
	<eladr@mellanox.com>, <yotamg@mellanox.com>, <nogahf@mellanox.com>,
	<ogerlitz@mellanox.com>, "Ido Schimmel" <idosch@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0063.outbound.protection.outlook.com ([104.47.1.63]:35063
	"EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754182AbcHDSNl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 14:13:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patches 1 and 2 fix a problem in which PAUSE frames settings are wrongly
overridden when ieee_setpfc() gets called.

Patch 3 adds a missing rollback in port's creation error path.

Ido Schimmel (3):
  mlxsw: spectrum: Do not assume PAUSE frames are disabled
  mlxsw: spectrum: Do not override PAUSE settings
  mlxsw: spectrum: Add missing DCB rollback in error path

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c | 10 ++++++----
 2 files changed, 7 insertions(+), 4 deletions(-)

-- 
2.8.2
