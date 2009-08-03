From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: Fix double pci unmapping.
Date: Sun, 02 Aug 2009 20:23:05 -0700 (PDT)
Message-ID: <20090802.202305.119004003.davem@davemloft.net>
References: <4A62C9DD.8040506@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60146
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752019AbZHCDW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 23:22:57 -0400
In-Reply-To: <4A62C9DD.8040506@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Sun, 19 Jul 2009 10:23:09 +0300

> 
> In cases of fragmented skb, with the data pointers being wrapped around
> the TX buffer, the completion handling code would not forward the data
> pointer and the firs fragment was unmapped several times, while others
> were not unmapped at all.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Ok, I'm just going to apply this.  Waiting more than a week to get
feedback from Roland for a bug fix like this is not reasonable.

Thanks Yevgeny.
