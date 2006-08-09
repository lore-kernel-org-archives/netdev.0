From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [PATCH] limit rt cache size
Date: Wed, 09 Aug 2006 12:05:33 +0400
Message-ID: <44D9974D.9010408@sw.ru>
References: <200608080711.06788.ak@suse.de> <Pine.LNX.4.61.0608081316330.2452@localhost.localdomain> <200608090123.01123.ak@suse.de> <20060808.171152.58440635.davem@davemloft.net> <Pine.LNX.4.61.0608081707410.2452@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ak@suse.de,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:33320 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S965096AbWHIIE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 04:04:56 -0400
To: akepner@sgi.com
In-Reply-To: <Pine.LNX.4.61.0608081707410.2452@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> 1) dynamic table growth is the only reasonable way to
>>   handle this and not waste memory in all cases
>> ....
> 
> 
> Definitely that's the ideal way to go.
> 
> But there's alot of state to update (more or less
> atomically, too) in the TCP hashes. Looks tricky to
> do that without hurting performance, especially since
> you'll probably want to resize the tables when you've
> discovered they're full and busy....
and the memory if fragmented too! :/

Kirill

