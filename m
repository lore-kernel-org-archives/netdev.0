From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: remove a sparse error
Date: Wed, 12 Jun 2013 15:03:47 -0700 (PDT)
Message-ID: <20130612.150347.1293098072802516.davem@davemloft.net>
References: <1371072195.3252.70.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756779Ab3FLWDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 18:03:48 -0400
In-Reply-To: <1371072195.3252.70.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 12 Jun 2013 14:23:15 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Fix following sparse error :
> 
> net/ipv4/af_inet.c:1410:59: warning: restricted __be16 degrades to
> integer
> 
> added in commit db8caf3dbc77599
> ("gro: should aggregate frames without DF")
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> From: Eric Dumazet <edumazet@google.com>

Applied.
