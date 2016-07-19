From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Safe flow for mlx4_en configuration change
Date: Tue, 19 Jul 2016 16:44:27 -0700 (PDT)
Message-ID: <20160719.164427.1323104974976513067.davem@davemloft.net>
References: <1468856112-17858-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbcGSXo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 19:44:29 -0400
In-Reply-To: <1468856112-17858-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Mon, 18 Jul 2016 18:35:10 +0300

> This patchset improves the mlx4_en driver resiliency, especially on
> systems with low memory.  Upon a configuration change that requires
> the allocation of new resources, we first try to allocate, prior to
> destroying the current ones.  Once it is successfully done,
> we release the old resources and attach the new ones.  Otherwise, we
> stay with a functioning interface having the same old configuration.
> 
> This improvement became of greater significance after removing the use
> of vmap.

Series applied, thanks.
