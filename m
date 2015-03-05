From: David Miller <davem@davemloft.net>
Subject: Re: I can tell no FIB
Date: Thu, 05 Mar 2015 16:27:11 -0500 (EST)
Message-ID: <20150305.162711.545663291988773902.davem@davemloft.net>
References: <CAE4R7bBwrB8==aYuN9gYoADwZHDwr5zYjL3tL=jqPP24p74VUw@mail.gmail.com>
	<54F8C802.1010706@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbbCEV1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 16:27:16 -0500
In-Reply-To: <54F8C802.1010706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 05 Mar 2015 13:17:54 -0800

> On 03/05/2015 12:49 PM, Scott Feldman wrote:
>> Hi Alex, turns out you're required to take a mandatory week-long
>> vacation after your fourth patch set to net/ipv4/fib_*.  See you in a
>> week!  Take lots of pictures.
>>
>> -scott
> 
> Well I have one more set of 9 and then I will stop for a while.  I was
> planning to send it later tonight.  Then I can probably take that
> week-long vacation..
> 
> I'm going to drop the portion of the patches I had where I was
> up-levelling the key vector since I still don't have a solution for the
> extra costs of insertion/deletion from the trie.  Also I don't think it
> would work well with the merge of the main and local tries if that is
> the route we are planning to take.

Ok, where do you want to place the main/local tree patch then?

Scott's L3 work logically depends upon that, and actually I think
Scott is sending you on vacation so that he doesn't have to rebase so
much :-)
