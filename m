From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net/atm: move all compat_ioctl handling to
 atm/ioctl.c
Date: Wed, 11 Nov 2009 19:56:55 -0800 (PST)
Message-ID: <20091111.195655.65545882.davem@davemloft.net>
References: <200911111430.44361.arnd@arndb.de>
	<1257946490.25961.1396.camel@macbook.infradead.org>
	<200911111445.22673.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53690
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932163AbZKLD43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 22:56:29 -0500
In-Reply-To: <200911111445.22673.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 11 Nov 2009 14:45:22 +0100

> We have two implementations of the compat_ioctl handling for ATM, the
> one that we have had for ages in fs/compat_ioctl.c and the one added to
> net/atm/ioctl.c by David Woodhouse. Unfortunately, both versions are
> incomplete, and in practice we use a very confusing combination of the
> two.
> 
> For ioctl numbers that have the same identifier on 32 and 64 bit systems,
> we go directly through the compat_ioctl socket operation, for those that
> differ, we do a conversion in fs/compat_ioctl.c.
> 
> This patch moves both variants into the vcc_compat_ioctl() function,
> while preserving the current behaviour. It also kills off the COMPATIBLE_IOCTL
> definitions that we never use here.
> Doing it this way is clearly not a good solution, but I hope it is a
> step into the right direction, so that someone is able to clean up this
> mess for real.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
