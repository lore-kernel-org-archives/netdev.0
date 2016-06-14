From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix endianness error in icmpv6_err
Date: Tue, 14 Jun 2016 15:25:07 -0400 (EDT)
Message-ID: <20160614.152507.1771785005466989314.davem@davemloft.net>
References: <1465669926-16272-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49051 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898AbcFNTZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 15:25:09 -0400
In-Reply-To: <1465669926-16272-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 11 Jun 2016 20:32:06 +0200

> IPv6 ping socket error handler doesn't correctly convert the new 32 bit
> mtu to host endianness before using.
> 
> Cc: Lorenzo Colitti <lorenzo@google.com>
> Fixes: 6d0bfe22611602f ("net: ipv6: Add IPv6 support to the ping socket.")
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
