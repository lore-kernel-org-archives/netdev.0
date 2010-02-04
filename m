From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3 v4] macvtap driver
Date: Wed, 03 Feb 2010 20:21:04 -0800 (PST)
Message-ID: <20100203.202104.151098461.davem@davemloft.net>
References: <201001271104.20607.arnd@arndb.de>
	<201001302322.15237.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, kaber@trash.net, mst@redhat.com,
	herbert@gondor.apana.org.au, ogerlitz@voltaire.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52314
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757067Ab0BDEUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 23:20:51 -0500
In-Reply-To: <201001302322.15237.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 30 Jan 2010 23:22:15 +0100

> This is the fourth version of the macvtap driver,
> based on the comments I got for the last version
> I got a few days ago. Very few changes:
> 
> * release netdev in chardev open function so
>   we can destroy it properly.
> * Implement TUNSETSNDBUF
> * fix sleeping call in rcu_read_lock
> * Fix comment in namespace isolation patch
> * Fix small context difference to make it apply
>   to net-next
> 
> I can't really test here while travelling, so please
> give it a go if you're interested in this driver.

All applied to net-next-2.6, thanks!
