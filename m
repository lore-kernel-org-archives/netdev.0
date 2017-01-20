From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qcom/emac: claim the irq only when the device is
 opened
Date: Fri, 20 Jan 2017 12:19:01 -0500 (EST)
Message-ID: <20170120.121901.1924570978922182141.davem@davemloft.net>
References: <1484775745-14050-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33902 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751303AbdATRTj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:19:39 -0500
In-Reply-To: <1484775745-14050-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Wed, 18 Jan 2017 15:42:25 -0600

> During reset, functions emac_mac_down() and emac_mac_up() are called,
> so we don't want to free and claim the IRQ unnecessarily.  Move those
> operations to open/close.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

If you don't tell me what tree this is against in your Subject line,
I have to guess.

I don't like guessing.
