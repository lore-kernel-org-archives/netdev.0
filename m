From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: dereference of he_dev->rbps_virt in
 he_init_group()
Date: Mon, 28 Sep 2009 12:46:04 -0700 (PDT)
Message-ID: <20090928.124604.147370158.davem@davemloft.net>
References: <4ABE152F.20507@gmail.com>
	<20090926.202636.105018102.davem@davemloft.net>
	<4AC07AC3.1090707@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39632
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752398AbZI1Tpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 15:45:45 -0400
In-Reply-To: <4AC07AC3.1090707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Mon, 28 Sep 2009 10:58:43 +0200

> From: Juha Leppanen <juha_motorsportcom@luukku.com>
> Date: Sat, Sep 26, 2009 at 12:34 AM
> Subject: atm: he: memleak/negative indexing of arrays in he_init_group()
> 
> The prefix decrement causes a very long loop if pci_pool_alloc() failed
> in the first iteration. Also I swapped rbps and rbpl arguments.
> 
> Reported-by: Juha Leppanen <juha_motorsportcom@luukku.com>
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied, thanks.

Note that, by putting that From: line with Juha's info in it,
I assume that you want this person to be listed as the author
of the patch instead of you.
