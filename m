From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [PATCH 2/7] devlink: Adding NPAR permanent config parameters
Date: Thu, 19 Oct 2017 10:39:58 +0000
Message-ID: <AM0PR0502MB36839C516E78EF0C2C1E4B46BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-3-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "gospo@broadcom.com" <gospo@broadcom.com>
To: Steve Lin <steven.lin1@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0086.outbound.protection.outlook.com ([104.47.0.86]:4656
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751764AbdJSKkC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 06:40:02 -0400
In-Reply-To: <1508273069-40461-3-git-send-email-steven.lin1@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> DEVLINK_ATTR_PERM_CFG_NPAR_BW_RESERVATION_VALID: 1 to use
> BW_RESERVATION setting, 0 to ignore.
>=20
...
> DEVLINK_ATTR_PERM_CFG_NPAR_BW_LIMIT_VALID: 1 to use BW_LIMIT
> setting, 0 to ignore.

While it probably ties to different fields in your NVM layout why would the=
 user
require specific attributes for these? Why not have values in the actual
attributes indicating of this status?
