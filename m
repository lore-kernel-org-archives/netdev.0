From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC] Move dst->child loop from dst_ifdown to xfrm_dst_ifdown
Date: Tue, 15 Feb 2005 14:53:48 -0800
Message-ID: <20050215145348.36ed3508.davem@davemloft.net>
References: <20050131162201.GA1000@stilzchen.informatik.tu-chemnitz.de>
	<20050205052407.GA17266@gondor.apana.org.au>
	<20050204213813.4bd642ad.davem@davemloft.net>
	<20050205061110.GA18275@gondor.apana.org.au>
	<20050204221344.247548cb.davem@davemloft.net>
	<20050205064643.GA29758@gondor.apana.org.au>
	<20050205201044.1b95f4e8.davem@davemloft.net>
	<20050206065117.GC16057@gondor.apana.org.au>
	<20050208012929.GA30659@gondor.apana.org.au>
	<20050208013140.GB30659@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mirko.parthey@informatik.tu-chemnitz.de, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, shemminger@osdl.org
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050208013140.GB30659@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 8 Feb 2005 12:31:40 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Feb 08, 2005 at 12:29:29PM +1100, herbert wrote:
> > 
> > This one moves the dst->child processing from dst_ifdown into
> > xfrm_dst_ifdown.
> 
> This patch adds a net_device argument to ifdown.  After all,
> it's a bit silly to notify someone of an ifdown event without
> telling them what which device it was for :)
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Ok, I'm going to try and get these two patches into 2.6.11
