From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] Revert "netvsc: optimize calculation of number
 of slots"
Date: Tue, 25 Jul 2017 21:27:23 -0700 (PDT)
Message-ID: <20170725.212723.757677468799150125.davem@davemloft.net>
References: <20170725040319.5969-1-sthemmin@microsoft.com>
        <20170725040319.5969-2-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        devel@linuxdriverproject.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39182 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750813AbdGZE1Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 00:27:24 -0400
In-Reply-To: <20170725040319.5969-2-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 24 Jul 2017 21:03:19 -0700

> The logic for computing page buffer scatter does not take into
> account the impact of compound pages. Therefore the optimization
> to compute number of slots was incorrect and could cause stack
> corruption a skb was sent with lots of fragments from huge pages.
> 
> This reverts commit 60b86665af0dfbeebda8aae43f0ba451cd2dcfe5.
> 
> Fixes: 60b86665af0d ("netvsc: optimize calculation of number of slots")
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
