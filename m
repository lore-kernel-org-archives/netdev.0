From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bcm63xx_enet: timeout off by one in do_mdio_op()
Date: Wed, 30 Sep 2009 20:05:51 -0700 (PDT)
Message-ID: <20090930.200551.139237447.davem@davemloft.net>
References: <4AB7DD50.6030409@gmail.com>
	<1254319288.1627.758.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35323
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755522AbZJADFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 23:05:31 -0400
In-Reply-To: <1254319288.1627.758.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxime Bizon <mbizon@freebox.fr>
Date: Wed, 30 Sep 2009 16:01:28 +0200

> 
> On Mon, 2009-09-21 at 22:08 +0200, Roel Kluin wrote:
> 
> Hi Roel,
> 
>> `while (limit-- >= 0)' reaches -2 after the loop upon timeout.
> 
> The 1000us limit was chosen arbitrarily, since mdio access are much
> shorter, and was just to prevent CPU lockup in case of hardware bug.
> 
> But it looks like a bug, and since you're the second one reporting this,
> this should be fixed :)
> 
> 
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> 
> Acked-by: Maxime Bizon <mbizon@freebox.fr>

Applied, thanks.
