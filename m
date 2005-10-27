From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Thu, 27 Oct 2005 16:42:34 +0200
Message-ID: <4360E75A.10405@trash.net>
References: <4352EEC8.9000602@trash.net>
	<20051017.094919.56989341.yoshfuji@linux-ipv6.org>
	<4352FD49.4090201@trash.net>
	<20051017014629.GB32661@gondor.apana.org.au>
	<435EBB18.50701@trash.net>
	<20051025231049.GA13679@gondor.apana.org.au>
	<435EBC57.7090000@trash.net>
	<20051026003954.GA14068@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20051026003954.GA14068@gondor.apana.org.au>
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
> On Wed, Oct 26, 2005 at 01:14:31AM +0200, Patrick McHardy wrote:
> 
>>No. I thought of this as a special case of inner transport mode SAs
>>(without any further SAs) which would be unhandled. I've never used
>>pure transport mode SAs except for testing, and I've never seen any
>>other users of this. Do you think it is important to handle?
> 
> 
> Well the scenario is IPv4 transport mode ESP applied outside normal
> IPIP tunnel devices.
> 
> Actually, this could work if we make sure that the user-space KMs
> set the SA selectors properly in this case.
> 
> I presume that you will be changing the output path so that LOCAL_OUT
> does not see the plain-text packet.  Otherwise it'll be asymmetric with
> repsect to the inbound side which does not see plain-text packets for
> transport mode SAs.

Yes, that was the idea. But since people seem to consider this an
important case to handle I'm going to try the per-SA flag you
proposed. I'll send new patches in the next days.
