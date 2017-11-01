From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] cxgb4: add hash-filter support to
 tc-flower offload
Date: Wed, 01 Nov 2017 22:06:53 +0900 (KST)
Message-ID: <20171101.220653.563151645621599544.davem@davemloft.net>
References: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com
To: rahul.lakkireddy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53812 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752154AbdKANHD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 09:07:03 -0400
In-Reply-To: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Date: Wed,  1 Nov 2017 08:52:58 +0530

> This series of patches add support to create hash-filters; a.k.a
> exact-match filters, to tc-flower offload.  T6 supports creating
> ~500K hash-filters in hw and can theoretically be expanded up to
> ~1 million.
> 
> Patch 1 fetches and saves the configured hw filter tuple field shifts
> and filter mask.
> 
> Patch 2 initializes the driver to use hash-filter configuration.
> 
> Patch 3 adds support to create hash filters in hw.
> 
> Patch 4 adds support to delete hash filters in hw.
> 
> Patch 5 adds support to retrieve filter stats for hash filters.
> 
> Patch 6 converts the flower table to use rhashtable instead of
> static hlist.
> 
> Patch 7 finally adds support to create hash filters via tc-flower
> offload.

Series applied, thanks.
