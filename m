From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Sun, 18 Dec 2005 23:59:35 +0100
Message-ID: <43A5E9D7.8050705@trash.net>
References: <438270F2.3000603@trash.net>	<20051123.193824.38162996.yoshfuji@linux-ipv6.org>	<43A571B5.205@trash.net>
	<20051219.001504.32143116.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kazunori@miyazawa.org, kozakai@linux-ipv6.org, davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20051219.001504.32143116.yoshfuji@linux-ipv6.org>
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

YOSHIFUJI Hideaki / $B5HF#1QL@ wrote:
> In article <43A571B5.205@trash.net> (at Sun, 18 Dec 2005 15:27:01 +0100), Patrick McHardy <kaber@trash.net> says:
> 
>>How about this patch instead? It eliminates the nhoffp argument
>>to IPv6 protocol handlers by storing it in the IP6CB, which allows
>>to call ip6_input_finish a second time and have it skip already
>>parsed headers and also gets rid of the manual hopopts skipping.
> 
> 
> The idea to store IP6CB itself seems sane to me.
> 
> BTW, we're now using full of skb->cb
> (and we are even exceeding it w/ mobile-ipv6 extensions)...

Not in mainline so far, so maybe we can fit your extensions
and my patches without the mobile extensions, that apparently
exceed the CB anyway, in there for now. Can I look at those
patches somewhere? BTW, other fields in the IP6CB seem to
store offsets in u16 fields, is this OK for nhoff too? I
thought with jumbo options I need to use a u32 field.
