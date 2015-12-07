From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Set DF bit for IPv4 GRE tunnels with fixed TTL
Date: Sun, 06 Dec 2015 22:37:14 -0500 (EST)
Message-ID: <20151206.223714.1293196518780536858.davem@davemloft.net>
References: <56634F31.3000609@shemyak.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	pshelar@nicira.com
To: konstantin@shemyak.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34764 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755165AbbLGDhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 22:37:16 -0500
In-Reply-To: <56634F31.3000609@shemyak.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Shemyak <konstantin@shemyak.com>
Date: Sat, 5 Dec 2015 22:55:13 +0200

> The DF bit on IPv4 GRE tunnels with fixed TTL is enforced in order
> to prevent networking loops. This was the original behavior of GRE
> tunnels, lost in the refactoring.
> 
> Signed-off-by: Konstantin Shemyak <konstantin@shemyak.com>

Like Pravin said, ip_tunnel_ioctl() does this already, the code
you are adding is superfluous.
