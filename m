From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] jme: Fix device PM wakeup API usage
Date: Mon, 07 Mar 2016 15:40:02 -0500 (EST)
Message-ID: <20160307.154002.1727124227884131032.davem@davemloft.net>
References: <1457136716-7251-1-git-send-email-cooldavid@cooldavid.org>
	<1457136716-7251-2-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, diego.viola@gmail.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54039 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838AbcCGUkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:40:04 -0500
In-Reply-To: <1457136716-7251-2-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: cooldavid@cooldavid.org
Date: Sat,  5 Mar 2016 08:11:56 +0800

> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
> 
> According to Documentation/power/devices.txt
> 
> The driver should not use device_set_wakeup_enable() which is the policy
> for user to decide.
> 
> Using device_init_wakeup() to initialize dev->power.should_wakeup and
> dev->power.can_wakeup on driver initialization.
> 
> And use device_may_wakeup() on suspend to decide if WoL function should
> be enabled on NIC.
> 
> Reported-by: Diego Viola <diego.viola@gmail.com>
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Applied.
