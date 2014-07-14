From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: sysctl - simplify address calculation of gc_*
 variables
Date: Mon, 14 Jul 2014 14:33:18 -0700 (PDT)
Message-ID: <20140714.143318.1099738757410344842.davem@davemloft.net>
References: <1405197404-19127-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, spender@grsecurity.net
To: minipli@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756122AbaGNVdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 17:33:19 -0400
In-Reply-To: <1405197404-19127-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>
Date: Sat, 12 Jul 2014 22:36:44 +0200

> The code in neigh_sysctl_register() relies on a specific layout of
> struct neigh_table, namely that the 'gc_*' variables are directly
> following the 'parms' member in a specific order. The code, though,
> expresses this in the most ugly way.
> 
> Get rid of the ugly casts and use the 'tbl' pointer to get a handle to
> the table. This way we can refer to the 'gc_*' variables directly.
> 
> Similarly seen in the grsecurity patch, written by Brad Spengler.
> 
> Signed-off-by: Mathias Krause <minipli@googlemail.com>
> Cc: Brad Spengler <spender@grsecurity.net>

Looks good, applied, thanks.
