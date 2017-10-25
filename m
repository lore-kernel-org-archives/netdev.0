From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [PATCH net-next v3 03/10] devlink: Adding num VFs per PF
 permanent config param
Date: Wed, 25 Oct 2017 05:41:07 +0000
Message-ID: <AM0PR0502MB36837D5478983730B6ADEFEBBF440@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
 <1508875962-39233-4-git-send-email-steven.lin1@broadcom.com>
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
Received: from mail-eopbgr40070.outbound.protection.outlook.com ([40.107.4.70]:32768
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751162AbdJYFlL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 01:41:11 -0400
In-Reply-To: <1508875962-39233-4-git-send-email-steven.lin1@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Adding DEVLINK_PERM_CONFIG_NUM_VF_PER_PF permanent config
> parameter.  Value is permanent, so becomes the new default
> value for this device.
>=20
> The value sets the number of VFs per PF in SR-IOV mode.

Assuming it's meant to directly control the PCIe capability value
I think you should mention it explicitly in the commit message.
