From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: Avoid accessing skb after
 submitting to input queue
Date: Thu, 26 Jan 2017 15:42:48 -0500 (EST)
Message-ID: <20170126.154248.1439762090689991124.davem@davemloft.net>
References: <20170126195235.GA3875@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43874 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751933AbdAZUoe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 15:44:34 -0500
In-Reply-To: <20170126195235.GA3875@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 26 Jan 2017 11:52:35 -0800

> From: Satanand Burla <satananda.burla@cavium.com>
> 
> Accessing skb after submitting to input queue can cause
> access to stale pointers if the skb ends up being transmitted
> and freed by that time.
> 
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied, thanks.
