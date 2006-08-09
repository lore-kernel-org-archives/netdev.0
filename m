From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [PATCH] limit rt cache size
Date: Wed, 09 Aug 2006 12:09:49 +0400
Message-ID: <44D9984D.9040304@sw.ru>
References: <200608080711.06788.ak@suse.de> <200608090123.01123.ak@suse.de> <20060808.171152.58440635.davem@davemloft.net> <200608090224.04158.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akepner@sgi.com,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:6503 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S965095AbWHIIJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 04:09:10 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200608090224.04158.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>2) for cases where we haven't implemented dynamic
>>   table growth, specifying a proper limit argument
>>   to the hash table allocation is a sufficient
>>   solution for the time being
> 
> 
> Agreed, just we don't know what the proper limits are. 
> 
> I guess it would need someone running quite a lot of benchmarks.
> Anyone volunteering? @)
In my original post I noted how it is quite easy to consume
the whole 1Gb of RAM on i686 PC (and it's only 4,194,304 entries)
it looks like with more IP addresses it is not that hard to
consume much more memory.

> Or do some cheesy default and document the options to change
> it clearly and wait for feedback from users on what works for
> them?

Kirill
