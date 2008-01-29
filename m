From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 2.6.24] fib_trie: apply fixes from fib_hash
Date: Mon, 28 Jan 2008 21:18:22 -0800 (PST)
Message-ID: <20080128.211822.46715588.davem@davemloft.net>
References: <Pine.LNX.4.58.0801261441470.7864@u.domain.uli>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@data.slu.se, netdev@vger.kernel.org,
	joonwpark81@gmail.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58892
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754473AbYA2FSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 00:18:05 -0500
In-Reply-To: <Pine.LNX.4.58.0801261441470.7864@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sat, 26 Jan 2008 14:44:36 +0200 (EET)

> 
> 	Update fib_trie with some fib_hash fixes:
> - check for duplicate alternative routes for prefix+tos+priority when
> replacing route
> - properly insert by matching tos together with priority
> - fix alias walking to use list_for_each_entry_continue for insertion
> and deletion when fa_head is not NULL
> - copy state from fa to new_fa on replace (not a problem for now)
> - additionally, avoid replacement without error if new route is same,
> as Joonwoo Park suggests.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Also applied, thanks a lot.
