From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] macsec: reference counting fixes
Date: Sat, 30 Jul 2016 21:11:26 -0700 (PDT)
Message-ID: <20160730.211126.727406615870890811.davem@davemloft.net>
References: <cover.1469782905.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbcGaEMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 00:12:12 -0400
In-Reply-To: <cover.1469782905.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri, 29 Jul 2016 15:37:52 +0200

> Patch 1 adds explicit reference counting on RXSCs, instead of the
> current implicit reference counting using the RXSA's refcount.
> 
> Patch 2 fixes possible kernel panics during module unload caused by an
> RCU callback that schedules another RCU callback, which the
> rcu_barrier() added in b196c22af5c3 ("macsec: add rcu_barrier() on
> module exit") didn't protect against.
> 
> Patch 3 fixes a refcounting issue with the underlying device for a
> macsec device when link creation fails.

Series applied, thanks Sabrina.
