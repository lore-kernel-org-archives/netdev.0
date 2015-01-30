From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 9/9] netfilter: nf_tables: add support for dynamic set
 updates
Date: Fri, 30 Jan 2015 21:18:02 +1100
Message-ID: <20150130101802.GA19073@gondor.apana.org.au>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
 <1422603994-5836-10-git-send-email-kaber@trash.net>
 <20150130092845.GA18725@gondor.apana.org.au>
 <C08F666A-DAAF-4C61-A9F3-DBB3D936B4B4@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, davem@davemloft.net, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <C08F666A-DAAF-4C61-A9F3-DBB3D936B4B4@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 30, 2015 at 10:08:46AM +0000, Patrick McHardy wrote:
> Am 30. Januar 2015 09:28:45 GMT+00:00, schrieb Herbert Xu <herbert@gondor.apana.org.au>:
> >On Fri, Jan 30, 2015 at 07:46:34AM +0000, Patrick McHardy wrote:
> >> Signed-off-by: Patrick McHardy <kaber@trash.net>
> >
> >I presume this can't create any jumps/gotos, right?
> 
> So far not, just data mappings. Not sure yet if there is a valid use case for jumps.

Well if they could create jumps/gotos in softirq context then
the loop verification would get pretty hairy :)

OK so it looks like you really do need a totally lockless walk.
So I'll reshape my iterators to do that.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
