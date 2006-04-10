From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 6349] New: iptables DNAT returns unknown
 error 4294967295
Date: Sun, 09 Apr 2006 22:39:07 -0700 (PDT)
Message-ID: <20060409.223907.11399328.davem@davemloft.net>
References: <20060407142331.26e6b653.akpm@osdl.org>
	<4437A3B9.8000000@trash.net> <4437A552.902@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmb@pochta.ru, akpm@osdl.org, netfilter-devel@lists.netfilter.org,
	netdev@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <4437A552.902@trash.net>
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

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 08 Apr 2006 13:58:10 +0200

> Patrick McHardy wrote:
> > Please try if this patch helps.
> > 
> > +	.hooks		= 1 << NF_IP_PRE_ROUTING || 1 << NF_IP_LOCAL_OUT,
> 
> I shouldn't send patches before getting out of bed .. :)
> 
> Please try this one instead.

I'm applying this to my tree.

If it's wrong for some reason, we still have time in the 2.6.17-X
devel cycle to correct it.
