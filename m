From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [PATCH net-next v3 02/10] devlink: Adding SR-IOV enablement perm
 config param
Date: Wed, 25 Oct 2017 05:41:07 +0000
Message-ID: <AM0PR0502MB368329B6254711078A056FEDBF440@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
 <1508875962-39233-3-git-send-email-steven.lin1@broadcom.com>
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
Received: from mail-he1eur01on0040.outbound.protection.outlook.com ([104.47.0.40]:55904
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750972AbdJYFlK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 01:41:10 -0400
In-Reply-To: <1508875962-39233-3-git-send-email-steven.lin1@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Adding DEVLINK_PERM_CONFIG_SRIOV_ENABLED permanent config
> parameter.  Value is permanent, so becomes the new default
> value for this device.
>=20
>   0 =3D Disable SR-IOV
>   1 =3D Enable SR-IOV

Does this imposes a requirement on the PCIe specifics, E.g., that the devic=
e
should no longer expose the SRIOV PCie capability?
Or does any implementation that would prevent a user from activating
SR-IOV is sufficient?
