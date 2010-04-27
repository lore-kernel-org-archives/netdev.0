From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: manual merge of the tty tree with the net tree
Date: Tue, 27 Apr 2010 08:14:34 -0700
Message-ID: <20100427151434.GD7653@kroah.com>
References: <20100427135706.259fa9c9.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Pavan Savoy <pavan_savoy@ti.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:44791 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753349Ab0D0POu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 11:14:50 -0400
Content-Disposition: inline
In-Reply-To: <20100427135706.259fa9c9.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 27, 2010 at 01:57:06PM +1000, Stephen Rothwell wrote:
> Hi Greg,
> 
> Today's linux-next merge of the tty tree got a conflict in
> include/linux/tty.h between commit
> 9b27105b4a44c54bf91ecd7d0315034ae75684f7 ("net-caif-driver: add CAIF
> serial driver (ldisc)") from the net tree and commit
> f3150d54db0e0caa1871f66b2424f463a34a7e7b ("serial: TTY: new ldiscs for
> staging") from the tty tree.
> 
> I fixed it up (they both changed NR_LDISCS - I used the higher number) and
> can carry the fix as necessary.

Thanks, the higher number should be what is needed here.

greg k-h
