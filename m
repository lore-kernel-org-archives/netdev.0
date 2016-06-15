From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] macsec fixes
Date: Wed, 15 Jun 2016 14:47:57 -0700 (PDT)
Message-ID: <20160615.144757.2302432790207142724.davem@davemloft.net>
References: <cover.1465908271.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161212AbcFOVr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 17:47:59 -0400
In-Reply-To: <cover.1465908271.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue, 14 Jun 2016 15:25:13 +0200

> Patch 1 adds rcu_barrier() during module unload to prevent possible
> panics.
> 
> Patch 2 allocates memory for scattergather lists and the IV on the
> heap, since they can escape the current function's context during
> crypto callbacks.
> 
> Patch 3 fixes a failure to create secure associations.

Series applied.
