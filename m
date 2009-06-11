From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter 00/31: netfilter update
Date: Thu, 11 Jun 2009 15:54:38 +0200
Message-ID: <4A310C9E.3050904@trash.net>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>	<20090610.234618.116984779.davem@davemloft.net> <20090611.010827.193702616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090611.010827.193702616.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 10 Jun 2009 23:46:18 -0700 (PDT)
> 
>> From: Patrick McHardy <kaber@trash.net>
>> Date: Wed, 10 Jun 2009 21:46:22 +0200 (MEST)
>>
>>> Please apply or pull from:
>>>
>>> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master
>> Pulled, thanks a lot Patrick.
>>
>> I'll push it back out to kernel.org after some build testing.
> 
> This stuff isn't ready, sorry I had to undo my pull:
> 
> net/netfilter/nf_conntrack_proto_tcp.c: In function 'tcp_packet':
> net/netfilter/nf_conntrack_proto_tcp.c:947: error: 'tcp_lock' undeclared (first use in this function)
> net/netfilter/nf_conntrack_proto_tcp.c:947: error: (Each undeclared identifier is reported only once
> net/netfilter/nf_conntrack_proto_tcp.c:947: error: for each function it appears in.)
> make[2]: *** [net/netfilter/nf_conntrack_proto_tcp.o] Error 1
> make[2]: *** Waiting for unfinished jobs....

That odd, my tree doesn't have a single reference to tcp_lock left.
I'll check what went wrong, sorry.

