From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/2] net: ethernet: hisilicon: set dev->dev.parent before
 PHY connect
Date: Mon, 12 Dec 2016 08:29:06 -0800
Message-ID: <cf29a8cb-2e26-6f89-ffc3-ed25779e5c1a@gmail.com>
References: <1481544223-207906-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: xuejiancheng@hisilicon.com, benjamin.chenhao@hisilicon.com,
        caizhiyong@hisilicon.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Dongpo Li <lidongpo@hisilicon.com>, yisen.zhuang@huawei.com,
        salil.mehta@huawei.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34442 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752748AbcLLQ3I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 11:29:08 -0500
In-Reply-To: <1481544223-207906-1-git-send-email-lidongpo@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2016 04:03 AM, Dongpo Li wrote:
> This patch series builds atop:
> ec988ad78ed6d184a7f4ca6b8e962b0e8f1de461 ("phy: Don't increment MDIO bus
> refcount unless it's a different owner")
> 
> I have checked all the hisilicon ethernet driver and found only two drivers
> need to be fixed to make sure set dev->dev.parent before PHY connect.

Thanks for doing this, these two drivers did not show up on my list
because I did not see them calling SET_NETDEV_DEV() so late.
-- 
Florian
