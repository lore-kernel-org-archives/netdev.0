From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: linux-next: manual merge of the net tree with the wireless tree
Date: Wed, 6 Oct 2010 09:27:08 -0400
Message-ID: <20101006132708.GC2472@tuxdriver.com>
References: <20101006120908.ffe99876.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dan Carpenter <error27@gmail.com>,
	Joe Perches <joe@perches.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44314 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932240Ab0JFNaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 09:30:08 -0400
Content-Disposition: inline
In-Reply-To: <20101006120908.ffe99876.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 06, 2010 at 12:09:08PM +1100, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> drivers/net/wireless/ipw2x00/ipw2200.c between commit
> 2ee4e27cf25ab647137713ca16377d8d9e138ea2 ("ipw2200: check for allocation
> failures") from the wireless tree and commit
> baeb2ffab4e67bb9174e6166e070a9a8ec94b0f6 ("drivers/net: Convert unbounded
> kzalloc calls to kcalloc") from the net tree.
> 
> Just context changes.  I fixed it up (see below) and can carry the fix as
> necessary.

That looks correct to me -- thanks!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
