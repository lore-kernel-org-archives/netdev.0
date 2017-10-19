From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 2/6] devlink: Adding SR-IOV enablement NVRAM
 config param
Date: Thu, 19 Oct 2017 21:33:46 +0200
Message-ID: <20171019193346.GE1978@nanopsycho.orion>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-3-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, davem@davemloft.net,
        michael.chan@broadcom.com, linville@tuxdriver.com,
        gospo@broadcom.com
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:53765 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751325AbdJSTds (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 15:33:48 -0400
Received: by mail-wm0-f66.google.com with SMTP id q132so18421055wmd.2
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 12:33:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1508440630-25830-3-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 19, 2017 at 09:17:06PM CEST, steven.lin1@broadcom.com wrote:
>Adding DEVLINK_PERM_CONFIG_SRIOV_ENABLED permanent config
>parameter.  If value is 1, SR-IOV is enabled.  If value is 0,
>SR-IOV is disabled on this device.  Value is permanent (stored
>in NVRAM), so becomes the new default value for this device.
>
>Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>Acked-by: Andy Gospodarek <gospo@broadcom.com>
>---
> include/uapi/linux/devlink.h | 5 +++++
> 1 file changed, 5 insertions(+)
>
>diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
>index 47cc584..2640203 100644
>--- a/include/uapi/linux/devlink.h
>+++ b/include/uapi/linux/devlink.h
>@@ -255,4 +255,9 @@ enum devlink_dpipe_header_id {
> 	DEVLINK_DPIPE_HEADER_IPV6,
> };
> 
>+/* Permanent (NVRAM) config parameters */

We need the decription here in the header as well. Commit message alone
is no good for this.

Also, there should not be mention of "NVRAM". It is up to the device
implementation where is stores the value.


>+enum devlink_perm_config_param {
>+	DEVLINK_PERM_CONFIG_SRIOV_ENABLED,
>+};
>+
> #endif /* _UAPI_LINUX_DEVLINK_H_ */
>-- 
>2.7.4
>
