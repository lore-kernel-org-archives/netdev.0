From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 09/13]: [NETFILTER]: Redo policy lookups after NAT when
 neccessary
Date: Sun, 20 Nov 2005 17:43:00 +0100
Message-ID: <4380A794.5050400@trash.net>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163139.16666.30437.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
In-Reply-To: <20051120163139.16666.30437.sendpatchset@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> [NETFILTER]: Redo policy lookups after NAT when neccessary
> 
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -195,13 +195,18 @@ static inline int ip_finish_output2(stru
>  		return dst->neighbour->output(skb);
>  
>  	if (net_ratelimit())
> -		printk(KERN_DEBUG "ip_finish_output2: No header cache and no neighbour!\n");
> +		printk(KERN_DEBUG "ip_finish_output3: No header cache and no neighbour!\n");
>  	kfree_skb(skb);
>  	return -EINVAL;
>  }

Damnit .. if you apply the patches please edit out this chunk,
its a remnant from an earlier series.

Thanks.
