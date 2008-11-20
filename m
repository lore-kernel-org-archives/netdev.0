From: Ben Greear <greearb@candelatech.com>
Subject: Re: ARP table question
Date: Thu, 20 Nov 2008 09:23:53 -0800
Message-ID: <49259D29.3070308@candelatech.com>
References: <49221929.7060504@candelatech.com>	<49221CE1.9000807@hp.com>	<49221F7A.8030706@candelatech.com> <20081120.003306.213001819.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60158 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471AbYKTRX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 12:23:59 -0500
In-Reply-To: <20081120.003306.213001819.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

>> After some more testing, I can still get it into a bad
>> state if I have a retrans timer of 1 sec and a randomness of 5 secs
>> and manage to cause all 1000 arp entries to go stale at once (by
>> yanking a cable, for instance).
>>
>> It seems I have to bump up the base timer to 3-5 seconds (I'm
>> leaving the random backoff at 5 secs as well).
> 
> This scheme still seems hackish to me, so I'm going to defer on this
> for now.

You think something like an exponential backoff capped at some user-configurable
max-value would be better?


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

