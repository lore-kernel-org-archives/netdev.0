From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net neigh: RCU conversion of neigh hash table
Date: Tue, 05 Oct 2010 14:55:15 -0700 (PDT)
Message-ID: <20101005.145515.216763626.davem@davemloft.net>
References: <1286208944.18293.349.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46757
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755925Ab0JEVyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 17:54:54 -0400
In-Reply-To: <1286208944.18293.349.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 04 Oct 2010 18:15:44 +0200

> [PATCH net-next] net neigh: RCU conversion of neigh hash table
> 
> Instead of storing hash_buckets, hash_mask and hash_rnd in "struct
> neigh_table", a new structure is defined :
> 
> struct neigh_hash_table {
>        struct neighbour        **hash_buckets;
>        unsigned int            hash_mask;
>        __u32                   hash_rnd;
>        struct rcu_head         rcu;
> };
> 
> And "struct neigh_table" has an RCU protected pointer to such a
> neigh_hash_table.
> 
> This means the signature of (*hash)() function changed: We need to add a
> third parameter with the actual hash_rnd value, since this is not
> anymore a neigh_table field.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Also applied.

Looking good so far! :)
