From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: Remove atomic context inside
 vortex_{set|get}_wol
Date: Wed, 15 Sep 2010 14:36:25 -0700 (PDT)
Message-ID: <20100915.143625.58442873.davem@davemloft.net>
References: <4C909CAD.8010905@kernel.org>
	<1284547021.2495.1.camel@edumazet-laptop>
	<4C90A6E6.8040608@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, ben@decadent.org.uk
To: dkirjanov@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57271
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754241Ab0IOVgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 17:36:07 -0400
In-Reply-To: <4C90A6E6.8040608@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <dkirjanov@kernel.org>
Date: Wed, 15 Sep 2010 14:58:46 +0400

> [PATCH v2] 3c59x: Remove atomic context inside vortex_{set|get}_wol
> 
> There is no need to use spinlocks in vortex_{set|get}_wol.
> This also fixes a bug:
...
> vortex_set_wol protected with a spinlock, but nested  acpi_set_WOL acquires a mutex inside atomic context.
> Ethtool operations are already serialized by RTNL mutex, so it is safe to drop the locks.
> 
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
> ---
> V2: fixed comments issue

Applied, thanks.
