From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: remove unnecessary initializations in
 net_dev_init
Date: Tue, 21 Jan 2014 16:45:09 -0800 (PST)
Message-ID: <20140121.164509.974672410731486941.davem@davemloft.net>
References: <1390069167-14080-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbaAVApK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 19:45:10 -0500
In-Reply-To: <1390069167-14080-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Sat, 18 Jan 2014 19:19:27 +0100

> softnet_data is already set to 0, no need to use memset or initialize
> specific fields to 0 or NULL afterwards.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied, thanks.
