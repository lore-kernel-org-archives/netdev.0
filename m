From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_gre: fix endianness errors in ip6gre_err
Date: Thu, 05 Feb 2015 00:34:09 -0800 (PST)
Message-ID: <20150205.003409.897935142442548489.davem@davemloft.net>
References: <1423059909-15606-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965766AbbBEIeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 03:34:10 -0500
In-Reply-To: <1423059909-15606-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Wed,  4 Feb 2015 15:25:09 +0100

> info is in network byte order, change it back to host byte order
> before use. In particular, the current code sets the MTU of the tunnel
> to a wrong (too big) value.
> 
> Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied.
