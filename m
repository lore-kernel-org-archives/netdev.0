From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 5/6] devlink: Adding num MSI-X vectors per VF
 NVRAM config param
Date: Thu, 19 Oct 2017 23:39:55 +0200
Message-ID: <20171019213955.GG1978@nanopsycho.orion>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-6-git-send-email-steven.lin1@broadcom.com>
 <AM0PR0502MB368347E87E48F7EB04AF1513BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Lin <steven.lin1@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "gospo@broadcom.com" <gospo@broadcom.com>
To: Yuval Mintz <yuvalm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:44315 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751524AbdJSVj6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 17:39:58 -0400
Received: by mail-wm0-f65.google.com with SMTP id 196so17409646wma.1
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 14:39:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AM0PR0502MB368347E87E48F7EB04AF1513BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 19, 2017 at 10:32:21PM CEST, yuvalm@mellanox.com wrote:
>> Adding DEVLINK_PERM_CONFIG_MSIX_VECTORS_PER_VF permanent
>> config
>> parameter.  Defines number of MSI-X vectors allocated per VF.
>> Value is permanent (stored in NVRAM), so becomes the new default
>> value for this device.
>
>Sounds like you're having this enforce the same configuration for all child VFs.

Yeah, this sounds like per-port config.


>
>> 
>> Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>> Acked-by: Andy Gospodarek <gospo@broadcom.com>
>> ---
>>  include/uapi/linux/devlink.h | 1 +
>>  1 file changed, 1 insertion(+)
>> 
>> diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
>> index 8ad6c63..ef163b6 100644
>> --- a/include/uapi/linux/devlink.h
>> +++ b/include/uapi/linux/devlink.h
>> @@ -260,6 +260,7 @@ enum devlink_perm_config_param {
>>  	DEVLINK_PERM_CONFIG_SRIOV_ENABLED,
>>  	DEVLINK_PERM_CONFIG_NUM_VF_PER_PF,
>>  	DEVLINK_PERM_CONFIG_MAX_NUM_PF_MSIX_VECT,
>> +	DEVLINK_PERM_CONFIG_MSIX_VECTORS_PER_VF,
>>  };
>> 
>>  #endif /* _UAPI_LINUX_DEVLINK_H_ */
>> --
>> 2.7.4
>
