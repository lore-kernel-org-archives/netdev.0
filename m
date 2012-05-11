From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] tcp: Move rcvq sending to tcp_input.c
Date: Thu, 10 May 2012 23:25:16 -0400 (EDT)
Message-ID: <20120510.232516.938107386195724427.davem@davemloft.net>
References: <4FABAB39.6090201@parallels.com>
	<4FABAB55.5050803@parallels.com>
	<1336651214.12504.149.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932498Ab2EKDZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 23:25:20 -0400
In-Reply-To: <1336651214.12504.149.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 May 2012 14:00:14 +0200

> On Thu, 2012-05-10 at 15:49 +0400, Pavel Emelyanov wrote:
>> It actually works on the input queue and will use its read mem
>> routines, thus it's better to have in in the tcp_input.c file.
>> 
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>> ---
>>  include/net/tcp.h    |    3 +--
>>  net/ipv4/tcp.c       |   33 ---------------------------------
>>  net/ipv4/tcp_input.c |   35 ++++++++++++++++++++++++++++++++++-
>>  3 files changed, 35 insertions(+), 36 deletions(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.

 
