From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH net-next v2 2/6] devlink: Adding SR-IOV enablement NVRAM
 config param
Date: Thu, 19 Oct 2017 16:40:09 -0400
Message-ID: <CA+Jmh7FBQLSStwO-Sn7Q_1vLOx9SSwUJ8_7S3=gWe7+ZJc23Fw@mail.gmail.com>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-3-git-send-email-steven.lin1@broadcom.com> <20171019193346.GE1978@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:53144 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751953AbdJSUka (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 16:40:30 -0400
Received: by mail-qt0-f196.google.com with SMTP id 31so16081464qtz.9
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 13:40:30 -0700 (PDT)
In-Reply-To: <20171019193346.GE1978@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 3:33 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Oct 19, 2017 at 09:17:06PM CEST, steven.lin1@broadcom.com wrote:
>>Adding DEVLINK_PERM_CONFIG_SRIOV_ENABLED permanent config
>>parameter.  If value is 1, SR-IOV is enabled.  If value is 0,
>>SR-IOV is disabled on this device.  Value is permanent (stored
>>in NVRAM), so becomes the new default value for this device.
>>
>>Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
>>Acked-by: Andy Gospodarek <gospo@broadcom.com>
>>---
>> include/uapi/linux/devlink.h | 5 +++++
>> 1 file changed, 5 insertions(+)
>>
>>diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
>>index 47cc584..2640203 100644
>>--- a/include/uapi/linux/devlink.h
>>+++ b/include/uapi/linux/devlink.h
>>@@ -255,4 +255,9 @@ enum devlink_dpipe_header_id {
>>       DEVLINK_DPIPE_HEADER_IPV6,
>> };
>>
>>+/* Permanent (NVRAM) config parameters */
>
> We need the decription here in the header as well. Commit message alone
> is no good for this.
>
> Also, there should not be mention of "NVRAM". It is up to the device
> implementation where is stores the value.
>
>

Will do, I'll add descriptions in the header file and reword as
requested.  Thanks!
