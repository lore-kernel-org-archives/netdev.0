From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] ethernet: qualcomm: QCOM_EMAC should depend on HAS_DMA
Date: Thu, 6 Oct 2016 09:06:43 -0500
Message-ID: <57F65A73.7020701@codeaurora.org>
References: <1475762253-16759-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33111 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932178AbcJFOGq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 10:06:46 -0400
In-Reply-To: <1475762253-16759-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Geert Uytterhoeven wrote:
>   config QCOM_EMAC
>   	tristate "Qualcomm Technologies, Inc. EMAC Gigabit Ethernet support"
> +	depends on HAS_DMA

I think it needs to depend on HAS_IOMEM as well, to fix this error in 
arch/um:

    drivers/net/ethernet/qualcomm/emac/emac.c: In function 'emac_remove':
 >> drivers/net/ethernet/qualcomm/emac/emac.c:727:3: error: implicit 
declaration of function 'iounmap' [-Werror=implicit-function-declaration]
       iounmap(adpt->phy.digital);

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
