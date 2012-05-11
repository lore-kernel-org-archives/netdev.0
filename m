From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] tcp: Schedule rmem for rcvq repair send
Date: Thu, 10 May 2012 23:25:19 -0400 (EDT)
Message-ID: <20120510.232519.2214325214697824251.davem@davemloft.net>
References: <4FABAB39.6090201@parallels.com>
	<4FABAB69.70401@parallels.com>
	<1336651229.12504.150.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56630 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932498Ab2EKDZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 23:25:22 -0400
In-Reply-To: <1336651229.12504.150.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 May 2012 14:00:29 +0200

> On Thu, 2012-05-10 at 15:50 +0400, Pavel Emelyanov wrote:
>> As noted by Eric, no checks are performed on the data size we're
>> putting in the read queue during repair. Thus, validate the given
>> data size with the common rmem management routine.
>> 
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>> ---
>>  net/ipv4/tcp_input.c |    3 +++
>>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
