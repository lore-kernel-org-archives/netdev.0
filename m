From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: fix race condition in mvneta_tx()
Date: Mon, 08 Dec 2014 20:55:59 -0500 (EST)
Message-ID: <20141208.205559.267421979148480413.davem@davemloft.net>
References: <1417523459.5303.39.camel@edumazet-glaptop2.roam.corp.google.com>
	<1417523835.5303.41.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141202124043.GB16347@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	maggie.mae.roxas@gmail.com, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com,
	ezequiel.garcia@free-electrons.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59267 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754688AbaLIB4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 20:56:02 -0500
In-Reply-To: <20141202124043.GB16347@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Tue, 2 Dec 2014 13:40:43 +0100

> On Tue, Dec 02, 2014 at 04:37:15AM -0800, Eric Dumazet wrote:
>> On Tue, 2014-12-02 at 04:30 -0800, Eric Dumazet wrote:
>> > From: Eric Dumazet <edumazet@google.com>
>> > 
>> > mvneta_tx() dereferences skb to get skb->len too late,
>> > as hardware might have completed the transmit and TX completion
>> > could have freed the skb from another cpu.
>> > 
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> 
>> 
>> 
>> For completeness, this bug was added in linux-3.14 and seems a stable
>> candidate.
>> 
>> Fixes: 71f6d1b31fb1 ("net: mvneta: replace Tx timer with a real interrupt")
> 
> Absolutely, we backported this one back to 3.10.

Applied, and queued up for -stable, thanks everyone.
