From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 1/3] rhashtable: don't test for shrink on insert,
 expansion on delete
Date: Fri, 20 Feb 2015 11:59:55 +0000
Message-ID: <20150220115955.GB4586@casper.infradead.org>
References: <cover.1424389682.git.daniel@iogearbox.net>
 <55e6cbcc9c4b7a831d72d3e3ec39c024f494f9e2.1424389682.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, johunt@akamai.com, netdev@vger.kernel.org,
	Ying Xue <ying.xue@windriver.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51375 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061AbbBTL75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 06:59:57 -0500
Content-Disposition: inline
In-Reply-To: <55e6cbcc9c4b7a831d72d3e3ec39c024f494f9e2.1424389682.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/15 at 12:53am, Daniel Borkmann wrote:
> Restore pre 54c5b7d311c8 behaviour and only probe for expansions on inserts
> and shrinks on deletes. Currently, it will happen that on initial inserts
> into a sparse hash table, we may i.e. shrink it first simply because it's
> not fully populated yet, only to later realize that we need to grow again.
> 
> This however is counter intuitive, e.g. an initial default size of 64
> elements is already small enough, and in case an elements size hint is given
> to the hash table by a user, we should avoid unnecessary expansion steps,
> so a shrink is clearly unintended here.
> 
> Fixes: 54c5b7d311c8 ("rhashtable: introduce rhashtable_wakeup_worker helper function")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Ying Xue <ying.xue@windriver.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
