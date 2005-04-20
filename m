From: "David S. Miller" <davem@davemloft.net>
Subject: [Openswan dev] Re: [IPSEC] COW skb header in UDP decap
Date: Tue, 19 Apr 2005 23:17:41 -0700
Message-ID: <20050419231741.64e44443.davem@davemloft.net>
References: <21730.1112984853@marajade.sandelman.ottawa.on.ca>
	<20050409010124.GA22059@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dev@lists.openswan.org
Return-path: <dev-bounces@openswan.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050409010124.GA22059@gondor.apana.org.au>
Cc: mcr@sandelman.ottawa.on.ca
Cc: netdev@oss.sgi.com
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@openswan.org>
List-Help: <mailto:dev-request@openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@openswan.org?subject=subscribe>
Sender: dev-bounces@openswan.org
Errors-To: dev-bounces@openswan.org
List-Id: netdev.vger.kernel.org

On Sat, 9 Apr 2005 11:01:24 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > I think that this fixes the problem. I must admit to being a bit
> 
> Thanks for the patch.  I think we can use something a little lighter
> than skb_unshare.  The following patch just makes the header part of
> the skb writeable.  This is needed since we modify the IP headers
> just a few lines below.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks a lot Herbert.
