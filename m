From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skbuff: don't zero tc members when
 freeing skb
Date: Fri, 02 Jan 2015 16:05:00 -0500 (EST)
Message-ID: <20150102.160500.1791727400349422767.davem@davemloft.net>
References: <1420029221-4296-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53253 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314AbbABVFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 16:05:01 -0500
In-Reply-To: <1420029221-4296-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 31 Dec 2014 13:33:41 +0100

> Not needed, only four cases:
>  - kfree_skb (or one of its aliases).
>    Don't need to zero, memory will be freed.
>  - kfree_skb_partial and head was stolen:  memory will be freed.
>  - skb_morph:  The skb header fields (including tc ones) will be
>    copied over from the 'to-be-morphed' skb right after
>    skb_release_head_state returns.
>  - skb_segment:  Same as before, all the skb header
>    fields are copied over from the original skb right away.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Agreed, applied, thanks Florian.
