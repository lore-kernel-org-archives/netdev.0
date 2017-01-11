From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: thunderx: Make hfunc variable const
 type in nicvf_set_rxfh()
Date: Wed, 11 Jan 2017 16:13:07 -0500 (EST)
Message-ID: <20170111.161307.1442732653533967340.davem@davemloft.net>
References: <20170111170432.31210-1-rrichter@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgoutham@cavium.com, rric@kernel.org, netdev@vger.kernel.org
To: rrichter@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59596 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760272AbdAKVNg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 16:13:36 -0500
In-Reply-To: <20170111170432.31210-1-rrichter@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Richter <rrichter@cavium.com>
Date: Wed, 11 Jan 2017 18:04:32 +0100

> From struct ethtool_ops:
> 
>         int     (*set_rxfh)(struct net_device *, const u32 *indir,
>                             const u8 *key, const u8 hfunc);
> 
> Change function arg of hfunc to const type.
> 
> V2: Fixed indentation.
> 
> Signed-off-by: Robert Richter <rrichter@cavium.com>

Applied.
