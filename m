From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net neigh: Optimize neighbor entry size
 calculation.
Date: Tue, 29 Jan 2013 00:04:36 -0500 (EST)
Message-ID: <20130129.000436.1681326851044319952.davem@davemloft.net>
References: <51011087.1010801@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033Ab3A2FEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 00:04:39 -0500
In-Reply-To: <51011087.1010801@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Jan 2013 19:44:23 +0900

> When allocating memory for neighbour cache entry, if
> tbl->entry_size is not set, we always calculate
> sizeof(struct neighbour) + tbl->key_len, which is common
> in the same table.
> 
> With this change, set tbl->entry_size during the table
> initialization phase, if it was not set, and use it in
> neigh_alloc() and neighbour_priv().
> 
> This change also allow us to have both of protocol private
> data and device priate data at tha same time.
> 
> Note that the only user of prototcol private is DECnet
> and the only user of device private is ATM CLIP.
> Since those are exclusive, we have not been facing issues
> here.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks.
