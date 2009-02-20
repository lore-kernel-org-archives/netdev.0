From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iptables: lock free counters
Date: Fri, 20 Feb 2009 10:42:27 +0100
Message-ID: <499E7B03.9090409@trash.net>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.321329022@vyatta.com>	<20090219114719.560999b5@extreme> <499DEF49.3040602@cosmosbay.com>	<499DF1A2.1030405@hp.com> <20090219170318.3f7d54f2@extreme> <499E04C9.4020308@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499E04C9.4020308@hp.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
>>>> Thanks Stephen, thats very cool stuff, yet another rwlock out of 
>>>> kernel :)
>>>
>>> Do you folks need/want further testing against the 32-core setup?
>>
>>
>> It would be good to combine all 3 (iptables-rcu, timer change, and 
>> conntrack lock)
>> to see what the overhead change is.
> 
> Fair enough. Is there a tree somewhere I can pull with all those in it, 
> or do I need to go back through the emails and apply patches?

You can use my nf-next.git tree from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git

It contains the lock free counters, as well as smaller optimizations
from Eric. The last timer patch I've seen missed the actual conversion
to use mod_timer_pending(), but it would be great to have some numbers
on the conntrack lock changes. Thanks Rick!
