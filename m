From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skbuff: const-ify casts in skb_queue_*
 functions
Date: Tue, 07 Jan 2014 18:34:20 -0500 (EST)
Message-ID: <20140107.183420.1204341569870279609.davem@davemloft.net>
References: <1389133424-11176-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45924 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754521AbaAGXeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 18:34:23 -0500
In-Reply-To: <1389133424-11176-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue,  7 Jan 2014 23:23:44 +0100

> We should const-ify comparisons on skb_queue_* inline helper
> functions as their parameters are const as well, so lets not
> drop that.
> 
> Suggested-by: Brad Spengler <spender@grsecurity.net>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Also applied, thanks Daniel.
