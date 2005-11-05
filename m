From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Sat, 05 Nov 2005 11:05:26 +0100
Message-ID: <436C83E6.7040907@trash.net>
References: <20051027121545.GA5530@gondor.apana.org.au>
	<20051027.235732.01166239.yoshfuji@linux-ipv6.org>
	<20051105063030.GA32385@gondor.apana.org.au>
	<436C6580.6030007@trash.net>
	<20051105083955.GA30293@gondor.apana.org.au>
	<436C7430.5030707@trash.net>
	<20051105090904.GA30733@gondor.apana.org.au>
	<436C7937.9070901@trash.net>
	<20051105093821.GA30966@gondor.apana.org.au>
	<436C81AD.7070308@trash.net>
	<20051105100137.GA31158@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20051105100137.GA31158@gondor.apana.org.au>
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

Herbert Xu wrote:
> On Sat, Nov 05, 2005 at 10:55:57AM +0100, Patrick McHardy wrote:
> 
>>In my last patchset I did it by calling netif_rx at that point,
>>now I want to add new hooks.
> 
> The only problem I can see is that at some point we're probably
> going to add an AF_PACKET hook there as well for the pure transport
> mode packet so that people can diagnose their transport mode IPsec
> problems.

Yes, that would be useful.

> However, I reckon that's still miles ahead of passing the packet
> back through netif_rx when we already know that it's still the
> same address family as what we started out with.

Great. I'm moving to a new appartment right now and will be offline
until monday. I'll try to get some patches ready until then.

Regards
Patrick
