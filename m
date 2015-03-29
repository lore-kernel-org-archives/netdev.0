From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Fixes ingress queue mapping and other fixes
Date: Sun, 29 Mar 2015 12:26:09 -0700 (PDT)
Message-ID: <20150329.122609.1477118155699381969.davem@davemloft.net>
References: <1427344466-17658-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408AbbC2TR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 15:17:26 -0400
In-Reply-To: <1427344466-17658-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu, 26 Mar 2015 10:04:24 +0530

> The below series fixes ingress queue mapping by allocating them dynamically to
> prevent stack overflow. Disable napi and interrupts before unregistering netdev
> to avoid crash while unloading driver when traffic is flowing.
> 
> The patches series is created against 'net' tree. 
> And includes patches on cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

Series applied, thanks.
