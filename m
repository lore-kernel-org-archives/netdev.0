From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/9] netfilter: netfilter update
Date: Sat, 03 Jul 2010 11:06:30 +0200
Message-ID: <4C2EFD96.1040907@trash.net>
References: <1278064342-19059-1-git-send-email-kaber@trash.net>	<20100702.220408.112596216.davem@davemloft.net> <20100702.224434.226764333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100702.224434.226764333.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 02 Jul 2010 22:04:08 -0700 (PDT)
>
>   
>> From: kaber@trash.net
>> Date: Fri,  2 Jul 2010 11:52:13 +0200
>>
>>     
>>> Please apply or pull from:
>>>
>>> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master
>>>       
>> Looks good, pulled, thanks Patrick.
>>     
>
> The br_netfilter changes don't build against net-next-2.6:
>
> net/bridge/br_netfilter.c: In function 'br_nf_pre_routing':
> net/bridge/br_netfilter.c:558:6: error: 'const struct net_device' has no member named 'br_port'
> net/bridge/br_netfilter.c:558:6: warning: type defaults to 'int' in declaration of '_________p1'
> net/bridge/br_netfilter.c:558:6: error: 'const struct net_device' has no member named 'br_port'
> net/bridge/br_netfilter.c:558:6: error: 'const struct net_device' has no member named 'br_port'
> net/bridge/br_netfilter.c:558:2: warning: type defaults to 'int' in type name
> net/bridge/br_netfilter.c:558:4: warning: assignment makes pointer from integer without a cast
> net/bridge/br_netfilter.c: In function 'br_nf_forward_arp':
> net/bridge/br_netfilter.c:730:6: error: 'const struct net_device' has no member named 'br_port'
> net/bridge/br_netfilter.c:730:6: warning: type defaults to 'int' in declaration of '_________p1'
>
> The br_port accessors got changed in net-next-2.6, so you have to do it using
> br_port_get_rcu(netdev) et al.
>   

Sorry, I added that patch to my tree after testing based on a merge
with net-next and forgot to retest.

> I'll fix this up in the merge commit when I pull.
>   

Thanks!

