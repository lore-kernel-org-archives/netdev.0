From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPv6 20/62: reassembly: replace magic number with macro definitions
Date: Tue, 16 Feb 2010 16:47:04 +0100
Message-ID: <4B7ABDF8.8010004@trash.net>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>	 <20100216145545.2796.47717.sendpatchset@x2.localnet> <1266335018.29987.50.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Shan Wei <shanwei@cn.fujitsu.com>, davem@davemloft.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1266335018.29987.50.camel@Joe-Laptop.home>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
>> @@ -246,6 +246,8 @@ extern int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb);
>>  int ip6_frag_nqueues(struct net *net);
>>  int ip6_frag_mem(struct net *net);
>>  
>> +#define IPV6_FRAG_HIGH_THRESH	262144		/* == 256*1024 */
>> +#define IPV6_FRAG_LOW_THRESH	196608		/* == 192*1024 */
>>  #define IPV6_FRAG_TIMEOUT	(60*HZ)		/* 60 seconds */
> 
> 196608 isn't a number I want to remember.
> Is this better as:
> 
> #define IPV6_FRAG_HIGH_THRESH	(256 * 1024)	/* 262144 */
> #define IPV6_FRAG_LOW_THRESH	(192 * 1024)	/* 196608 */

Please send a patch, I'll apply it once these patches are in Dave's
tree.
