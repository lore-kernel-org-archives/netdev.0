From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the staging tree with the net tree
Date: Thu, 06 Oct 2011 01:56:22 -0400 (EDT)
Message-ID: <20111006.015622.2047301950614681216.davem@davemloft.net>
References: <20111006160433.44de2a1374b6ec4efc97e04e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ian.Campbell@citrix.com,
	netdev@vger.kernel.org, mark.einon@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20111006160433.44de2a1374b6ec4efc97e04e@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 6 Oct 2011 16:04:33 +1100

> Today's linux-next merge of the staging tree got a conflict in
> drivers/staging/et131x/et1310_tx.c between commit bf3f1a6081aa ("et131x:
> convert to SKB paged frag API") from the net tree and commit 10f00a49b048
> ("staging: et131x: Rename var name 'etdev' to 'adapter' throughout
> module") from the staging tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.

Yep, we saw this one coming too.  I think you'll need to carry this one
until the merge window flushes out.

Thanks!
