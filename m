From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] net: ethernet: hip04: Call SET_NETDEV_DEV()
Date: Mon, 12 Dec 2016 08:28:31 -0800
Message-ID: <7b902ba5-86a6-4c97-a531-f61e62c5a6fd@gmail.com>
References: <1481544223-207906-1-git-send-email-lidongpo@hisilicon.com>
 <1481544223-207906-3-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: xuejiancheng@hisilicon.com, benjamin.chenhao@hisilicon.com,
        caizhiyong@hisilicon.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Dongpo Li <lidongpo@hisilicon.com>, yisen.zhuang@huawei.com,
        salil.mehta@huawei.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34177 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752817AbcLLQ2d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 11:28:33 -0500
In-Reply-To: <1481544223-207906-3-git-send-email-lidongpo@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2016 04:03 AM, Dongpo Li wrote:
> The hip04 driver calls into PHYLIB which now checks for
> net_device->dev.parent, so make sure we do set it before calling into
> any MDIO/PHYLIB related function.
> 
> Fixes: ec988ad78ed6 ("phy: Don't increment MDIO bus refcount unless it's a different owner")
> Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
