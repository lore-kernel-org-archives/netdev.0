From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Mon, 19 Dec 2005 00:15:04 +0900 (JST)
Message-ID: <20051219.001504.32143116.yoshfuji@linux-ipv6.org>
References: <438270F2.3000603@trash.net>
	<20051123.193824.38162996.yoshfuji@linux-ipv6.org>
	<43A571B5.205@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kozakai@linux-ipv6.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, kazunori@miyazawa.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net, davem@davemloft.net
In-Reply-To: <43A571B5.205@trash.net>
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

In article <43A571B5.205@trash.net> (at Sun, 18 Dec 2005 15:27:01 +0100), Patrick McHardy <kaber@trash.net> says:

> YOSHIFUJI Hideaki wrote:
> > In article <438270F2.3000603@trash.net> (at Tue, 22 Nov 2005 02:14:26 +0100), Patrick McHardy <kaber@trash.net> says:
> > 
> > 
> >>The easiest way would be to store nhoff somewhere in the skb and
> >>use it to continue at the next header. But I still hope there is
> >>a way without keeping data in the skb.
> > 
> > 
> > We've coded up this.
> 
> How about this patch instead? It eliminates the nhoffp argument
> to IPv6 protocol handlers by storing it in the IP6CB, which allows
> to call ip6_input_finish a second time and have it skip already
> parsed headers and also gets rid of the manual hopopts skipping.

The idea to store IP6CB itself seems sane to me.

BTW, we're now using full of skb->cb
(and we are even exceeding it w/ mobile-ipv6 extensions)...

--yoshfuji
