From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 4/7] net: qcom/emac: Fix module autoload for OF
 registration
Date: Mon, 17 Oct 2016 09:40:30 -0500
Message-ID: <5804E2DE.3010502@codeaurora.org>
References: <1476713146-26632-1-git-send-email-javier@osg.samsung.com>
 <1476713146-26632-5-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Javier Martinez Canillas <javier@osg.samsung.com>,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51534 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932273AbcJQOkd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:40:33 -0400
In-Reply-To: <1476713146-26632-5-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Javier Martinez Canillas wrote:
> If the driver is built as a module, autoload won't work because the module
> alias information is not filled. So user-space can't match the registered
> device with the corresponding module.
>
> Export the module alias information using the MODULE_DEVICE_TABLE() macro.
>
> Before this patch:
>
> $ modinfo drivers/net/ethernet/qualcomm/emac/qcom-emac.ko | grep alias
> alias:          platform:qcom-emac
>
> After this patch:
>
> $ modinfo drivers/net/ethernet/qualcomm/emac/qcom-emac.ko | grep alias
> alias:          platform:qcom-emac
> alias:          of:N*T*Cqcom,fsm9900-emacC*
> alias:          of:N*T*Cqcom,fsm9900-emac
>
> Signed-off-by: Javier Martinez Canillas<javier@osg.samsung.com>

Acked-by: Timur Tabi <timur@codeaurora.org>

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
