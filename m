From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] cxgb4: keep carrier off before registering
 netdev
Date: Tue, 30 May 2017 14:10:52 -0400 (EDT)
Message-ID: <20170530.141052.1095828939688163731.davem@davemloft.net>
References: <1496124126-18597-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, surendra@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54296 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750964AbdE3SK7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 14:10:59 -0400
In-Reply-To: <1496124126-18597-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Tue, 30 May 2017 11:32:06 +0530

> From: Surendra Mobiya <surendra@chelsio.com>
> 
> Mark carrier off before registering netdev to ensure that vlan device
> picks up the correct state of the carrier
> 
> Signed-off-by: Surendra Mobiya <surendra@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> ---
> v2:
> - keep carrier off before registering netdev not after

Looks better, applied, thanks.
