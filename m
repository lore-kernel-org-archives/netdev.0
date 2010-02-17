From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6.h: reassembly: replace calculated magic number
 with multiplication
Date: Tue, 16 Feb 2010 23:38:21 -0800 (PST)
Message-ID: <20100216.233821.260093505.davem@davemloft.net>
References: <1266335018.29987.50.camel@Joe-Laptop.home>
	<4B7ABDF8.8010004@trash.net>
	<1266381604.8446.17.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, shanwei@cn.fujitsu.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: joe@perches.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1266381604.8446.17.camel@Joe-Laptop.home>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 16 Feb 2010 20:40:04 -0800

> On Tue, 2010-02-16 at 16:47 +0100, Patrick McHardy wrote:
>> Joe Perches wrote:
>> >> @@ -246,6 +246,8 @@ extern int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb);
>> >>  int ip6_frag_nqueues(struct net *net);
>> >>  int ip6_frag_mem(struct net *net);
>> >>  
>> >> +#define IPV6_FRAG_HIGH_THRESH	262144		/* == 256*1024 */
>> >> +#define IPV6_FRAG_LOW_THRESH	196608		/* == 192*1024 */
>> >>  #define IPV6_FRAG_TIMEOUT	(60*HZ)		/* 60 seconds */
>> > 
>> > 196608 isn't a number I want to remember.
>> > Is this better as:
>> > 
>> > #define IPV6_FRAG_HIGH_THRESH	(256 * 1024)	/* 262144 */
>> > #define IPV6_FRAG_LOW_THRESH	(192 * 1024)	/* 196608 */
>> 
>> Please send a patch, I'll apply it once these patches are in Dave's
>> tree.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
