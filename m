From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next][v2] net: qcom/emac: claim the irq only when
 the device is opened
Date: Mon, 23 Jan 2017 13:03:41 -0500 (EST)
Message-ID: <20170123.130341.1571181724805215874.davem@davemloft.net>
References: <1484954464-2622-1-git-send-email-timur@codeaurora.org>
        <1484954464-2622-2-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LinoSanfilippo@gmx.de
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47776 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750738AbdAWSDv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 13:03:51 -0500
In-Reply-To: <1484954464-2622-2-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Fri, 20 Jan 2017 17:21:04 -0600

> During reset, functions emac_mac_down() and emac_mac_up() are called,
> so we don't want to free and claim the IRQ unnecessarily.  Move those
> operations to open/close.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>
> ---
> 
> Notes:
>     v2: keep synchronize_irq call where it is

Applied.
