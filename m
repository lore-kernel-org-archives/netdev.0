From: David Miller <davem@davemloft.net>
Subject: Re: TCP socket receives strange packet
Date: Tue, 14 Oct 2014 12:32:59 -0400 (EDT)
Message-ID: <20141014.123259.185699262217339879.davem@davemloft.net>
References: <543D2EB2.4000009@oktetlabs.ru>
	<1413298852.17109.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yurij.Plotnikov@oktetlabs.ru, netdev@vger.kernel.org,
	Alexandra.Kossovsky@oktetlabs.ru
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598AbaJNQdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 12:33:02 -0400
In-Reply-To: <1413298852.17109.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Oct 2014 08:00:52 -0700

> On Tue, 2014-10-14 at 18:09 +0400, Yurij M. Plotnikov wrote:
>> Connected TCP socket receives packet without timestamps option which 
>> exists in SYN, SYNACK and ACK. It is packet 4 in attached tcpdump output.
>> 
>> tcpdump output description: The host has address 10.208.10.1 (server) 
>> and the peer host has address 10.208.10.2 (client).
>> 
>> Establishing connection: Timestamps option exists in SYN, SYNACK and ACK 
>> (packets 1, 2 and 3 in attached file), so accepted socket should receive 
>> packets only with timestamps option.
> 
> Can you point the RFC paragraph stating so ?

There is no requirement that timestamps be present just because they
were successfuly negoatiated during the handshake.

This has been brought up before several times.
