From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: Re: [PATCH] resource release cleanup in net/
Date: Mon, 2 May 2005 01:21:50 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0505020119070.2488@dragon.hyggekrogen.localhost>
References: <Pine.LNX.4.62.0504302219520.2094@dragon.hyggekrogen.localhost>
 <20050501230843.GA16518@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Jouni Malinen <jkmaline@cc.hut.fi>,
	James Morris <jmorris@intercode.com.au>,
	Pedro Roque <roque@di.fc.ul.pt>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Kunihiro Ishiguro <kunihiro@ipinfusion.com>,
	Mitsuru KANDA <mk@linux-ipv6.org>,
	lksctp-developers@lists.sourceforge.net,
	Andy Adamson <andros@umich.edu>,
	Bruce Fields <bfields@umich.edu>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@oss.sgi.com, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050501230843.GA16518@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 May 2005, Herbert Xu wrote:

> On Sat, Apr 30, 2005 at 10:36:00PM +0200, Jesper Juhl wrote:
> > 
> > Since Andrew merged the patch that makes calling crypto_free_tfm() with a 
> > NULL pointer safe into 2.6.12-rc3-mm1, I made a patch to remove checks for 
> > NULL before calling that function, and while I was at it I removed similar 
> > redundant checks before calls to kfree() and vfree() in the same files. 
> > There are also a few tiny whitespace cleanups in there.
> 
> Hi Jesper:
> 
> Could we wait until the crypto_free_tfm patch gets into the main tree?
> Most people here track that instead of mm.
> 

Sure. I don't have a problem with that.

I'll just hold on to the patches and resend them at a later date.


-- 
Jesper 


