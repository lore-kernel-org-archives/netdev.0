From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Mon, 19 Dec 2005 12:46:22 +0900 (JST)
Message-ID: <20051219.124622.101716348.yoshfuji@linux-ipv6.org>
References: <43A571B5.205@trash.net>
	<20051219.001504.32143116.yoshfuji@linux-ipv6.org>
	<43A5E9D7.8050705@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kazunori@miyazawa.org, kozakai@linux-ipv6.org, davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <43A5E9D7.8050705@trash.net>
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

In article <43A5E9D7.8050705@trash.net> (at Sun, 18 Dec 2005 23:59:35 +0100), Patrick McHardy <kaber@trash.net> says:

> YOSHIFUJI Hideaki wrote:
:
> >  BTW, we're now using full of skb->cb
> > (and we are even exceeding it w/ mobile-ipv6 extensions)...
> 
> Not in mainline so far, so maybe we can fit your extensions
> and my patches without the mobile extensions, that apparently
> exceed the CB anyway, in there for now. Can I look at those
> patches somewhere? BTW, other fields in the IP6CB seem to
> store offsets in u16 fields, is this OK for nhoff too? I
> thought with jumbo options I need to use a u32 field.

Well, don't mind too much.
I just wanted to note that we're about to exceed skb->cb.
I will probably enlarge skb->cb if needed.

And, yes, good point.
I think nhoff should be u32 because it is critical.
In theory, u32 is definitely needed for others as well...

--yoshfuji
