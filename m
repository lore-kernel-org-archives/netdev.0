From: "David S. Miller" <davem@davemloft.net>
Subject: Re: pppoe and receive checksum offload
Date: Wed, 9 Mar 2005 21:13:15 -0800
Message-ID: <20050309211315.2dc86d44.davem@davemloft.net>
References: <20050224155906.73890361@dxpl.pdx.osdl.net>
	<20050228113106.GA3268@gondor.apana.org.au>
	<20050228113938.GA3393@gondor.apana.org.au>
	<20050228140401.GA27937@yakov.inr.ac.ru>
	<20050301010424.GA14851@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, shemminger@osdl.org, mostrows@speakeasy.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050301010424.GA14851@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 1 Mar 2005 12:04:24 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Feb 28, 2005 at 05:04:01PM +0300, Alexey Kuznetsov wrote:
> >
> > ppp_input() could do the same thing. It does not, hence suggested patch
> > is corrrect minimal solution.
> 
> Agreed.  We should use Stephen's patch for 2.6.11.
> 
> For 2.6.12, does this patch look sane? As usual, I'd love to get
> some better names for the new helper functions.

I'm not so picky about the names.  Patch applied, thanks
Herbert :-)

If Stephen cares, he can try to submit his patch for 2.6.11.x
via stable@kernel.org, I have no problem with that.
