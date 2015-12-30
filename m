From: David Miller <davem@davemloft.net>
Subject: Re: 4.4-rc7 failure report
Date: Wed, 30 Dec 2015 12:50:03 -0500 (EST)
Message-ID: <20151230.125003.301825767708169401.davem@davemloft.net>
References: <5683A630.2070401@iogearbox.net>
	<20151230151123.GB4874@codemonkey.org.uk>
	<1451494525.8255.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, dledford@redhat.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754731AbbL3RuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:50:05 -0500
In-Reply-To: <1451494525.8255.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Dec 2015 11:55:25 -0500

> On Wed, 2015-12-30 at 10:11 -0500, Dave Jones wrote:
>> On Wed, Dec 30, 2015 at 10:38:56AM +0100, Daniel Borkmann wrote:
>> 
>>  > Given that this drop doesn't strictly need to be caused by filter code,
>>  > it would be nice if you could pin the location down where the packet gets
>>  > dropped exactly. Perhaps dropwatch or perf with '-e skb:kfree_skb -a -g
>>  > dhclient <iface>', etc could help to get a first overview to dig into
>>  > details then.
>> 
>> Wild stab in the dark, but..
>> Could this bug be another symptom fixed by http://article.gmane.org/gmane.linux.network/392885 ?
> 
> dhclient does not use async io

But the bug causes requests to "LOOK" like async I/O, right?
