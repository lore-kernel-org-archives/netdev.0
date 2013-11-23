From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix leaking uninitialized port number of
 offender sockaddr
Date: Sat, 23 Nov 2013 14:49:13 -0800 (PST)
Message-ID: <20131123.144913.1974642959725806083.davem@davemloft.net>
References: <20131123062233.GD15822@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756474Ab3KWWkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 17:40:42 -0500
In-Reply-To: <20131123062233.GD15822@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 23 Nov 2013 07:22:33 +0100

> Offenders don't have port numbers, so set it to 0.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable.
