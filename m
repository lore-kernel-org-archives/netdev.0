From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] sfc: only use RSS filters if we're using RSS
Date: Sat, 12 Dec 2015 00:27:04 -0500 (EST)
Message-ID: <20151212.002704.1233703185682812026.davem@davemloft.net>
References: <56697E60.9050304@solarflare.com>
	<566A99D4.5010807@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbbLLF1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 00:27:06 -0500
In-Reply-To: <566A99D4.5010807@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Fri, 11 Dec 2015 09:39:32 +0000

> Without this, filter insertion on a VF would fail if only one channel
> was in use. This would include the unicast station filter and therefore
> no traffic would be received.
> 
> Signed-off-by: Bert Kenward <bkenward@solarflare.com>

Applied, thank you.
