From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: gigaset: add missing unlock
Date: Sat, 07 Aug 2010 23:04:28 -0700 (PDT)
Message-ID: <20100807.230428.216772079.davem@davemloft.net>
References: <20100806082323.GU9031@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hjlipp@web.de, tilman@imap.cc, isdn@linux-pingi.de,
	ext-andriy.shevchenko@nokia.com,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59012
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750972Ab0HHGEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 02:04:09 -0400
In-Reply-To: <20100806082323.GU9031@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Fri, 6 Aug 2010 10:23:23 +0200

> We should unlock here.  This is the only place where we return from the
> function with the lock held.  The caller isn't expecting it.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
