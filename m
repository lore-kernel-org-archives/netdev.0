From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [PATCH net-next v2 5/6] devlink: Adding num MSI-X vectors per VF
 NVRAM config param
Date: Thu, 19 Oct 2017 20:32:21 +0000
Message-ID: <AM0PR0502MB368347E87E48F7EB04AF1513BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-6-git-send-email-steven.lin1@broadcom.com>
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
Received: from mail-eopbgr20048.outbound.protection.outlook.com ([40.107.2.48]:31472
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753370AbdJSUcZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 16:32:25 -0400
In-Reply-To: <1508440630-25830-6-git-send-email-steven.lin1@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Adding DEVLINK_PERM_CONFIG_MSIX_VECTORS_PER_VF permanent
> config
> parameter.  Defines number of MSI-X vectors allocated per VF.
> Value is permanent (stored in NVRAM), so becomes the new default
> value for this device.

Sounds like you're having this enforce the same configuration for all child=
 VFs.

>=20
> Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
> Acked-by: Andy Gospodarek <gospo@broadcom.com>
> ---
>  include/uapi/linux/devlink.h | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
> index 8ad6c63..ef163b6 100644
> --- a/include/uapi/linux/devlink.h
> +++ b/include/uapi/linux/devlink.h
> @@ -260,6 +260,7 @@ enum devlink_perm_config_param {
>  	DEVLINK_PERM_CONFIG_SRIOV_ENABLED,
>  	DEVLINK_PERM_CONFIG_NUM_VF_PER_PF,
>  	DEVLINK_PERM_CONFIG_MAX_NUM_PF_MSIX_VECT,
> +	DEVLINK_PERM_CONFIG_MSIX_VECTORS_PER_VF,
>  };
>=20
>  #endif /* _UAPI_LINUX_DEVLINK_H_ */
> --
> 2.7.4
