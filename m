From: David Miller <davem@davemloft.net>
Subject: Re: iptables very slow after
 commit784544739a25c30637397ace5489eeb6e15d7d49
Date: Fri, 10 Apr 2009 18:25:07 -0700 (PDT)
Message-ID: <20090410.182507.140306636.davem@davemloft.net>
References: <Pine.LNX.4.64.0904101656190.2093@boston.corp.fedex.com>
	<20090410095246.4fdccb56@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff.chua.linux@gmail.com, dada1@cosmosbay.com, jengelh@medozas.de,
	kaber@trash.net, r000n@r000n.net, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090410095246.4fdccb56@s6510>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 10 Apr 2009 09:52:46 -0700

[ CC:'ing netfilter-devel and netdev... ]

> On Fri, 10 Apr 2009 17:15:52 +0800 (SGT)
> Jeff Chua <jeff.chua.linux@gmail.com> wrote:
> 
>> 
>> 
>> Adding 200 records in iptables took 6.0sec in 2.6.30-rc1 compared to 
>> 0.2sec in 2.6.29. I've bisected down this commit.
>> 
>> There are a few patches on top of the original patch. When I reverted the 
>> original commit + changing rcu_read() to rcu_read_bh(), it speeds up the 
>> inserts back to .2sec again.
>> 
>> I'm loading all the firewall rules during boot-up and this 6 secs slowness 
>> is really not very nice to wait for.
> 
> The performance benefit during operation is more important. The load
> time is fixable. The problem is probably generic to any set of rules,
> but could you post some info about your configuration (like the rule
> set), and the system configuration (# of cpu's, config etc).
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
