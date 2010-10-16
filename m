From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: move MII outside of NET_ETHERNET, fix
 kconfig warning
Date: Sat, 16 Oct 2010 11:58:55 -0700 (PDT)
Message-ID: <20101016.115855.179956240.davem@davemloft.net>
References: <20101013181859.fc3a96fd.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, jgarzik@pobox.com
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35291
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753612Ab0JPS6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 14:58:33 -0400
In-Reply-To: <20101013181859.fc3a96fd.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 13 Oct 2010 18:18:59 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> We have USB, PCMCIA, and gigabit ethernet drivers that select
> MII even though NET_ETHERNET is not enabled, so make MII not
> be dependent on NET_ETHERNET.  It is still dependent on NET
> and NETDEVICES.
> 
> Fixes kconfig unmet dependency warning (shortened, was very long string):
 ...
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Acked-by: Jeff Garzik <jgarzik@pobox.com> [2006-NOV-30]

Applied, and I added your infiniband patch too.

Thanks Randy.
