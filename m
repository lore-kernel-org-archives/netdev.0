From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [PATCH 5/7] devlink: Adding pre-boot permanent config parameters
Date: Thu, 19 Oct 2017 10:30:28 +0000
Message-ID: <AM0PR0502MB3683667E768C35276522780EBF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-6-git-send-email-steven.lin1@broadcom.com>
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
Received: from mail-he1eur01on0040.outbound.protection.outlook.com ([104.47.0.40]:12992
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751426AbdJSKab (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 06:30:31 -0400
In-Reply-To: <1508273069-40461-6-git-send-email-steven.lin1@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> DEVLINK_ATTR_PERM_CFG_MBA_LINK_SPEED: Configured link speed
> while executing MBA host software (PXI/iSCSI); use enum
> devlink_mba_link_speed.

#4 introduces:

> DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D0: Configure default
> pre-OS link speed in full power (D0) state; use enum
> devlink_pre_os_link_speed.

> DEVLINK_ATTR_PERM_CFG_PRE_OS_LINK_SPEED_D3: Configure default
> pre-OS link speed in sleep (D3) state; use enum
> devlink_pre_os_link_speed.

Why would user need an additional value for the MBA speed?
