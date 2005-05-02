From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: CONFIG_NETFILTER_DEBUG spew
Date: Tue, 3 May 2005 07:36:12 +1000
Message-ID: <20050502213612.GD16177@gondor.apana.org.au>
References: <20050501032809.3d0b4cda.akpm@osdl.org>
	<20050501111507.GA2133@gondor.apana.org.au>
	<4276517F.6030606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4276517F.6030606@trash.net>
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

On Mon, May 02, 2005 at 06:12:47PM +0200, Patrick McHardy wrote:
> Herbert Xu wrote:
> > BTW, should we do nf_reset in ip_dev_loopback_xmit as well?
> 
> I think we should, tc actions could do something unexpected with
> the packet.

Looks good to me.  Thanks Patrick.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
