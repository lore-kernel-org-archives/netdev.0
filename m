From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-next-2.6 2011-02-22
Date: Fri, 25 Feb 2011 14:48:13 -0500
Message-ID: <20110225194812.GG15897@tuxdriver.com>
References: <20110222215229.GJ12153@tuxdriver.com>
 <20110224.224344.104068328.davem@davemloft.net>
 <20110225.111500.59674472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, padovan@profusion.mobi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51648 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932648Ab1BYUAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 15:00:42 -0500
Content-Disposition: inline
In-Reply-To: <20110225.111500.59674472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 25, 2011 at 11:15:00AM -0800, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 24 Feb 2011 22:43:44 -0800 (PST)

> > Pulled, thanks a lot John.
> 
> John a few things:
> 
> 1) I had to add some vmalloc.h includes to fix the build on sparc64,
>    see commit b08cd667c4b6641c4d16a3f87f4550f81a6d69ac in net-next-2.6

I have a patch in my tree for that -- seems they hit it on ARM as well.

> 2) Something is screwey with the bluetooth config options now.
> 
>    I have an allmodconfig tree, and when I run "make oldconfig" after
>    this pull, BT_L2CAP and BT_SCO both prompt me, claiming that they
>    can only be built statically.
> 
>    I give it 'y' just to make it happen, for both, and afterways no
>    matter how many times I rerun "make oldconfig" I keep seeing things
>    like this in my build:
> 
> scripts/kconfig/conf --silentoldconfig Kconfig
> include/config/auto.conf:986:warning: symbol value 'm' invalid for BT_SCO
> include/config/auto.conf:3156:warning: symbol value 'm' invalid for BT_L2CAP
> 
>    First, what the heck is going on here?  Second, why the heck can't these
>    non-trivial pieces of code be built modular any more?
> 
>    You can't make something "bool", have it depend on something that
>    might be modular, and then build it into what could in fact be a
>    module.  That's exactly what the bluetooth stuff seems to be doing
>    now.
> 
>    I suspect commit 642745184f82688eb3ef0cdfaa4ba632055be9af
> 
> Thanks.

Sorry, I overlooked that.  Hopefully Gustavo will figure it out quickly.

Thanks,

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
