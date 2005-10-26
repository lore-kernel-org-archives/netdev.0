From: James Morris <jmorris@namei.org>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Wed, 26 Oct 2005 00:39:16 -0400 (EDT)
Message-ID: <Pine.LNX.4.63.0510260038200.18717@excalibur.intercode>
References: <4352EEC8.9000602@trash.net>
	<20051017.094919.56989341.yoshfuji@linux-ipv6.org>
	<4352FD49.4090201@trash.net>
	<20051017014629.GB32661@gondor.apana.org.au>
	<435EBB18.50701@trash.net> <20051025231049.GA13679@gondor.apana.org.au>
	<435EBC57.7090000@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <435EBC57.7090000@trash.net>
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

On Wed, 26 Oct 2005, Patrick McHardy wrote:

> No. I thought of this as a special case of inner transport mode SAs
> (without any further SAs) which would be unhandled. I've never used
> pure transport mode SAs except for testing, and I've never seen any
> other users of this. Do you think it is important to handle?

Pure transport mode SAs are likely to be common when using IPSec labeling 
(the stuff Trent Jaeger has been working on).


- James
-- 
James Morris
<jmorris@namei.org>
