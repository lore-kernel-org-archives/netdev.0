From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qcom/emac: disable interrupts before calling
 phy_disconnect
Date: Sat, 15 Oct 2016 17:35:06 -0400 (EDT)
Message-ID: <20161015.173506.1915898679977419991.davem@davemloft.net>
References: <1476472475-12104-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36464 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752203AbcJOVfK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 17:35:10 -0400
In-Reply-To: <1476472475-12104-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Fri, 14 Oct 2016 14:14:35 -0500

> There is a race condition that can occur if EMAC interrupts are
> enabled when phy_disconnect() is called.  phy_disconnect() sets
> adjust_link to NULL.  When an interrupt occurs, the ISR might
> call phy_mac_interrupt(), which wakes up the workqueue function
> phy_state_machine().  This function might reference adjust_link,
> thereby causing a null pointer exception.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Applied.
