From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iptables: lock free counters
Date: Mon, 02 Mar 2009 11:55:29 +0100
Message-ID: <49ABBB21.9080401@trash.net>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.321329022@vyatta.com> <20090219114719.560999b5@extreme> <499DEF49.3040602@cosmosbay.com> <49A7F262.8040805@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49A7F262.8040805@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> # time iptables -nvL
> Chain INPUT (policy ACCEPT 416M packets, 64G bytes)
>  pkts bytes target     prot opt in     out     source               destination
> 
> Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
>  pkts bytes target     prot opt in     out     source               destination
> 
> Chain OUTPUT (policy ACCEPT 401M packets, 62G bytes)
>  pkts bytes target     prot opt in     out     source               destination
> 
> real    0m1.810s
> user    0m0.000s
> sys     0m0.001s

Thats really slow ...

> CONFIG_NO_HZ=y
> CONFIG_HZ_1000=y
> CONFIG_HZ=1000
> 
> One cpu is 100% handling softirqs, could it be the problem ?

Is this fixed by your RCU quiescent state fix?
