From: David Miller <davem@davemloft.net>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 15:35:08 -0500 (EST)
Message-ID: <20151118.153508.123902005995190872.davem@davemloft.net>
References: <1447819493.22599.137.camel@edumazet-glaptop2.roam.corp.google.com>
	<1447841988.834928.443071345.1AAFF2A9@webmail.messagingengine.com>
	<CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933160AbbKRUfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 15:35:10 -0500
In-Reply-To: <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Wed, 18 Nov 2015 19:47:21 +0900

> On Wed, Nov 18, 2015 at 7:19 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> I bet there will soon be a timewaitd which handles the not configurable
>> (David has rejected all those patches so far) timeout of TIME_WAIT
>> sockets. And I bet it will be used. :/
> 
> No, SOCK_DESTROY has no effect on TCP_TIME_WAIT sockets or any other
> non-full socket.
> 
> When called on any socket where sk_fullsock(sk) is false, it returns
> EOPNOTSUPP because there is nothing to do. Its purpose is to interrupt
> blocked userspace socket calls, not to release resources.

+1
