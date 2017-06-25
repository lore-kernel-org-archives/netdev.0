From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Don't log mc removal needlessly
Date: Sun, 25 Jun 2017 11:34:39 -0400 (EDT)
Message-ID: <20170625.113439.249450058761462835.davem@davemloft.net>
References: <20170624123700.8762-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40196 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751020AbdFYPfP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 11:35:15 -0400
In-Reply-To: <20170624123700.8762-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Sat, 24 Jun 2017 15:37:00 +0300

> When mc configuration changes bnx2x_config_mcast() can return 0 for
> success, negative for failure and positive for benign reason preventing
> its immediate work, e.g., when the command awaits the completion of
> a previously sent command.
> 
> When removing all configured macs on a 578xx adapter, if a positive
> value would be returned driver would errneously log it as an error.
> 
> Fixes: c7b7b483ccc9 ("bnx2x: Don't flush multicast MACs")
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied, thanks.
