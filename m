From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [PATCH 3/7] devlink: Adding high level dev perm config params
Date: Thu, 19 Oct 2017 10:36:52 +0000
Message-ID: <AM0PR0502MB3683B79EBF09CB3837098581BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-4-git-send-email-steven.lin1@broadcom.com>
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
Received: from mail-eopbgr10073.outbound.protection.outlook.com ([40.107.1.73]:52806
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751570AbdJSKgz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 06:36:55 -0400
In-Reply-To: <1508273069-40461-4-git-send-email-steven.lin1@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> DEVLINK_ATTR_PERM_CFG_MULTIFUNC_MODE: Configure multi-function
> mode; use devlink_multifunc_mode.
...
> +enum devlink_multifunc_mode {
> +	DEVLINK_MULTIFUNC_MODE_ALLOWED,		/* Ext switch
> activates MF */
> +	DEVLINK_MULTIFUNC_MODE_FORCE_SINGFUNC,
> +	DEVLINK_MULTIFUNC_MODE_NPAR10,		/* NPAR 1.0
> */
> +	DEVLINK_MULTIFUNC_MODE_NPAR15,		/* NPAR 1.5
> */
> +	DEVLINK_MULTIFUNC_MODE_NPAR20,		/* NPAR 2.0
> */
> +};

... And when someone would invent a new partitioning scheme, what then?
You'd extend the 'generic' modes?
It's not very generic.

> DEVLINK_ATTR_PERM_CFG_SECURE_NIC_ENABLED: 1 to enable Secure NIC
> functionality, 0 to disable.

What does it mean? Is there some spec explaining it?
