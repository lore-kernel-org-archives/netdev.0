From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] sit: fix prefix length of ll and v4mapped
 addresses
Date: Thu, 14 Nov 2013 16:59:32 -0500 (EST)
Message-ID: <20131114.165932.1323320586572793443.davem@davemloft.net>
References: <1384433467-4780-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754990Ab3KNV7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 16:59:36 -0500
In-Reply-To: <1384433467-4780-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 14 Nov 2013 13:51:05 +0100

> When the local IPv4 endpoint is wilcard (0.0.0.0), the prefix length is
> correctly set, ie 64 if the address is a link local one or 96 if the address is
> a v4 mapped one.
> But when the local endpoint is specified, the prefix length is set to 128 for
> both kind of address. This patch fix this wrong prefix length.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
