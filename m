From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-rps: Fix brokeness causing OOO packets
Date: Fri, 16 Nov 2012 14:36:51 -0500 (EST)
Message-ID: <20121116.143651.2017197744422750526.davem@davemloft.net>
References: <1353092655.10798.44.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877Ab2KPTgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 14:36:55 -0500
In-Reply-To: <1353092655.10798.44.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Nov 2012 11:04:15 -0800

> From: Tom Herbert <therbert@google.com>
> 
> In commit c445477d74ab3779 which adds aRFS to the kernel, the CPU
> selected for RFS is not set correctly when CPU is changing.
> This is causing OOO packets and probably other issues.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Applied and queued up for -stable, thanks everyone.
