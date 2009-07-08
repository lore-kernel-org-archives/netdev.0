From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix OF fixed-link property handling on Freescale
 network device drivers
Date: Tue, 07 Jul 2009 19:16:32 -0700 (PDT)
Message-ID: <20090707.191632.192291073.davem@davemloft.net>
References: <20090703221851.23909.923.stgit@localhost.localdomain>
	<20090707151241.GA26831@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@secretlab.ca, leoli@freescale.com,
	afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36416
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756310AbZGHCQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 22:16:30 -0400
In-Reply-To: <20090707151241.GA26831@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Tue, 7 Jul 2009 19:12:41 +0400

> ->restart() will dereference phydev, which is NULL.
> 
> grep for 'phydev' in fs_enet/mac-*.c.

Ok, so this patch still needs a little bit more work.

Thanks for testing!
