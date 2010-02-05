From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: linux-next: manual merge of the trivial tree with the net tree
Date: Fri, 5 Feb 2010 09:39:05 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1002050935470.15395@pobox.suse.cz>
References: <20100205133747.14ca83f2.sfr@canb.auug.org.au> <20100204.202645.18974249.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, adam.buchbinder@gmail.com,
	netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100204.202645.18974249.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 4 Feb 2010, David Miller wrote:

> > Today's linux-next merge of the trivial tree got a conflict in 
> > drivers/net/sfc/mcdi_pcol.h between commit 
> > 5297a98d5dd6de86fe1e2ffc9ea60cdf59b71443 ("sfc: Update MCDI protocol 
> > definitions") from the net tree and commit 
> > 4887b438e6880c73c4b44d868211e70c1f3deaec ("Fix misspelling of 
> > "successful" and variants in comments") from the trivial tree.
> > 
> > I fixed it up (see below) and can carry the fix as necessary.
> 
> Ugh, this is the second spelling fix that's hit a conflict
> in the same exact tree.
> 
> Please, submit these things to the subsystem maintainers instead
> of keeping them together in a totally seperate tree.  That way
> we won't have to keep fighting these things.

Well, no problem with that. 

Some maintainers just don't want to be buggered with such patches though, 
and I always take care of sending this queue to Linus only when all the 
trees which had conflict in linux-next are already in (and I do the 
conflict resolution myself), so this should be exactly zero additional 
work for subsystem maintainers.

But if you don't like this, I'll just start refusing all the trivial 
patches touching net/ and drivers/net/ and will redirect them your way.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
