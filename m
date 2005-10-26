From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Wed, 26 Oct 2005 09:37:33 +0200
Message-ID: <200510260937.33725.netdev@axxeo.de>
References: <4352EEC8.9000602@trash.net>
	<20051025231049.GA13679@gondor.apana.org.au>
	<435EBC57.7090000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <435EBC57.7090000@trash.net>
Content-Disposition: inline
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
> Herbert Xu wrote:
> > Actually I was thinking of transport mode SAs with no accompanying
> > tunnel mode SAs.  Did you have another way of dealing with them?
>
> No. I thought of this as a special case of inner transport mode SAs
> (without any further SAs) which would be unhandled. I've never used
> pure transport mode SAs except for testing, and I've never seen any
> other users of this. Do you think it is important to handle?

These become important in untrusted LANs. These days, the LAN is often 
not safe enough for confidental data, so you need end to end encryption,
for which tunnel mode is a bitch to setup (due to the additional routing
required ).

Regards

Ingo Oeser
