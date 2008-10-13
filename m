From: Adrian Bunk <bunk@kernel.org>
Subject: Re: Please pull - generic HDLC
Date: Mon, 13 Oct 2008 08:53:56 +0300
Message-ID: <20081013055356.GA29938@cs181140183.pp.htv.fi>
References: <m33aj15xhr.fsf@maximus.localdomain> <20081012.144704.39192150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:58872 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbYJMFy5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 01:54:57 -0400
Content-Disposition: inline
In-Reply-To: <20081012.144704.39192150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 12, 2008 at 02:47:04PM -0700, David Miller wrote:
> From: Krzysztof Halasa <khc@pm.waw.pl>
> Date: Sun, 12 Oct 2008 23:12:16 +0200
> 
> > David,
> > 
> > The following changes since commit
> > f3073ac76755abd63b1d4c3d145f4c15b65b5355 (i.e., your netdev-2.6):
> > Guennadi Liakhovetski (1): smc911x: Fix external PHY detection
> > 
> > are available in the git repository at:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git for-david
> 
> You've missed the networking merge window, as I stated the other
> day I'm not taking any more networking changes.
> 
> You should have merged this in earlier.
>...

Ignoring whether it will go into 2.6.28 or 2.6.29 there seems to be a 
more fundamental issue:

The over 3 weeks old -next already contains mostly the same as the HDLC 
tree contains now.

The thing you two should sort out is why the tree ended up as an own 
tree in -next instead of pull requests to David long ago.

E.g. the netdev and wireless trees also don't go into -next, but instead 
with frequent pull requests to David.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

