From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: dereference of he_dev->rbps_virt in
 he_init_group()
Date: Sat, 26 Sep 2009 20:26:36 -0700 (PDT)
Message-ID: <20090926.202636.105018102.davem@davemloft.net>
References: <4AB66240.6060703@gmail.com>
	<20090922.142532.24854998.davem@davemloft.net>
	<4ABE152F.20507@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36448
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753188AbZI0D0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2009 23:26:17 -0400
In-Reply-To: <4ABE152F.20507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sat, 26 Sep 2009 15:20:47 +0200

> he_dev->rbps_virt or he_dev->rbpl_virt allocation may fail, so
> check them. Make sure that he_init_group() cleans up after
> errors.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> Signed-off-by: "Juha Leppanen" <juha_motorsportcom@luukku.com>
> ---
> David, I swapped rbps and rbpl arguments in my last patch, and
> there were some other problems. This was pointed out by Juha
> Leppanen. Can you please replace the former patch by this one? 
> 
> This was version was build, sparse and checkpatch tested.
> 
> Sorry for the mess.

I can't just "replace" it, especially since your change is even
already in Linus's tree.

Please send me a relative fixup rather than a new patch.
