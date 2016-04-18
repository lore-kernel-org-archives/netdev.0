From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] macsec: fix crypto Kconfig dependency
Date: Tue, 19 Apr 2016 07:44:55 +1000
Message-ID: <20160419074455.10a96986@canb.auug.org.au>
References: <20160418080202.GA18155@gondor.apana.org.au>
	<11585265.Dbvl2xi4u3@wuerfel>
	<20160418104336.GA19175@gondor.apana.org.au>
	<20160418.124316.1862068166928198574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, arnd@arndb.de, sd@queasysnail.net,
	hannes@stressinduktion.org, johannes@sipsolutions.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160418.124316.1862068166928198574.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

On Mon, 18 Apr 2016 12:43:16 -0400 (EDT) David Miller <davem@davemloft.net> wrote:
>
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 18 Apr 2016 18:43:36 +0800
> 
> > Right, the problem is that nothing within crypto ever selects
> > CRYPTO since it's also used as a way of hiding the crypto menu
> > options.  
> 
> As far as I understand it, this won't help.  Because selects do not
> trigger other selects and dependencies.

My understanding is that selects trigger other selects, but do not
honour dependencies.  So, in general, you should not select a symbol
that has dependencies (unless you also have the same dependencies or
select those dependencies).

-- 
Cheers,
Stephen Rothwell
