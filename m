From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next] tun: implement BQL
Date: Tue, 13 Nov 2012 17:19:39 -0500 (EST)
Message-ID: <20121113.171939.1673751173342429141.davem@davemloft.net>
References: <20121112132241.12bb94e4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50553 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856Ab2KMWTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 17:19:40 -0500
In-Reply-To: <20121112132241.12bb94e4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 12 Nov 2012 13:22:41 -0800

> Add multiqueue BQL to tap device. Tested with VPN, doesn't have a big impact,
> most likely because there is little queueing occuring at TAP device except
> under case of forwarding.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I think unless we can show it making an impact in a normal
usage scenerio, we should leave it alone for now.
