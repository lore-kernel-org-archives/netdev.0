From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/compat: fix dev_ifsioc emulation corner cases
Date: Wed, 11 Nov 2009 19:56:40 -0800 (PST)
Message-ID: <20091111.195640.82952998.davem@davemloft.net>
References: <200911061500.01651.arnd@arndb.de>
	<20091110.204118.12070030.davem@davemloft.net>
	<200911111439.40753.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, patrick.ohly@intel.com,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53685
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756199AbZKLD4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 22:56:14 -0500
In-Reply-To: <200911111439.40753.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 11 Nov 2009 14:39:40 +0100

> Handling for SIOCSHWTSTAMP is broken on architectures
> with a split user/kernel address space like s390,
> because it passes a real user pointer while using
> set_fs(KERNEL_DS).
> A similar problem might arise the next time somebody
> adds code to dev_ifsioc.
> 
> Split up dev_ifsioc into three separate functions for
> SIOCSHWTSTAMP, SIOC*IFMAP and all other numbers so
> we can get rid of set_fs in all potentially affected
> cases.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.

> Resending this one as well, rebased to current net-next.
> Please tell me if you want a backport to 2.6.32 or -stable
> for this one.
> 

No.
