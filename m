From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [PATCH 4/7] devlink: Adding perm config of link settings
Date: Thu, 19 Oct 2017 06:07:30 +0000
Message-ID: <AM0PR0502MB36835F863A3E05376F3562B1BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-5-git-send-email-steven.lin1@broadcom.com>
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
Received: from mail-eopbgr10079.outbound.protection.outlook.com ([40.107.1.79]:49312
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750947AbdJSGHd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 02:07:33 -0400
In-Reply-To: <1508273069-40461-5-git-send-email-steven.lin1@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +enum devlink_autoneg_protocol {
> +	DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY_BAM,
> +	DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY_CONSORTIUM,
> +	DEVLINK_AUTONEG_PROTOCOL_IEEE8023BY,
> +	DEVLINK_AUTONEG_PROTOCOL_BAM,		/* Broadcom
> Autoneg Mode */
> +	DEVLINK_AUTONEG_PROTOCOL_CONSORTIUM,	/*
> Consortium Autoneg Mode */
> +};

Wouldn't adding BAM as a 'generic' mode of operation be like adding
non-consortium speeds to ethtool API?
[I profess ignorance in this area; For all I know it can be a widely accept=
ed
industry standard]
