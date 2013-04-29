From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 05/21] atm: he: use msleep instead of large udelay
 constants
Date: Mon, 29 Apr 2013 13:27:08 -0400 (EDT)
Message-ID: <20130429.132708.1188315001953129841.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7203@saturn3.aculab.com>
	<20130426091220.468cf59e@thirdoffive.cmf.nrl.navy.mil>
	<201304291513.27104.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, David.Laight@aculab.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201304291513.27104.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 29 Apr 2013 15:13:26 +0200

> From a0ddf082821b064cc2d6a9bb90861f9b81a559a5 Mon Sep 17 00:00:00 2001
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Thu, 14 Mar 2013 15:21:36 +0100
> Subject: [PATCH] atm: he: use mdelay instead of large udelay constants
> 
> ARM cannot handle udelay for more than 2 miliseconds, and
> it is rather bad style to block the cpu for 16ms anyway,
> so let's use msleep instead.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
