From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: thunderx: Make hfunc variable const type
 in nicvf_set_rxfh()
Date: Wed, 11 Jan 2017 10:51:02 -0500 (EST)
Message-ID: <20170111.105102.1947940014901244160.davem@davemloft.net>
References: <20170111091702.6343-1-rrichter@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgoutham@cavium.com, rric@kernel.org, netdev@vger.kernel.org
To: rrichter@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51594 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933792AbdAKPvE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 10:51:04 -0500
In-Reply-To: <20170111091702.6343-1-rrichter@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Richter <rrichter@cavium.com>
Date: Wed, 11 Jan 2017 10:17:02 +0100

> @@ -635,7 +635,7 @@ static int nicvf_get_rxfh(struct net_device *dev, u32 *indir, u8 *hkey,
>  }
>  
>  static int nicvf_set_rxfh(struct net_device *dev, const u32 *indir,
> -			  const u8 *hkey, u8 hfunc)
> +			const u8 *hkey, const u8 hfunc)

Please do not change the indentation, it is currently correct.
