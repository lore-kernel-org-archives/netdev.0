From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_make_synack() minor changes
Date: Wed, 26 Mar 2014 15:12:09 -0400 (EDT)
Message-ID: <20140326.151209.653481434539419400.davem@davemloft.net>
References: <1395853039.12610.217.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140326.142551.19958322633174107.davem@davemloft.net>
	<1395860927.12610.226.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544AbaCZTML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 15:12:11 -0400
In-Reply-To: <1395860927.12610.226.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Mar 2014 12:08:47 -0700

> On Wed, 2014-03-26 at 14:25 -0400, David Miller wrote:
>> Do you know where this "+ 15" comes from? :-)
>> 
>> It is a kind of Linux networking trivia question.
> 
> My random guess would be that it is related to a copy/paste
> thing, as some tx paths used to allocate skb with a very precise byte
> count, and they used HH_DATA_ALIGN().

Yes, this is exactly it.
