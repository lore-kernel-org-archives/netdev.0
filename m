From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add compat ioctl support for the ipv4 multicast
 ioctl SIOCGETSGCNT
Date: Thu, 03 Feb 2011 17:19:18 -0800 (PST)
Message-ID: <20110203.171918.28815936.davem@davemloft.net>
References: <201101301326.14390.arnd@arndb.de>
	<m18vy2tfzn.fsf@fess.ebiederm.org>
	<201101301959.53661.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, kaber@trash.net
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59480
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753585Ab1BDBSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 20:18:43 -0500
In-Reply-To: <201101301959.53661.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Sun, 30 Jan 2011 19:59:53 +0100

> * ip multicast actually needs support for SIOCGETVIFCNT in
>   addition to SIOCGETSGCNT to be complete.
> * ipv6 multicast needs the same patch as ipv4 multicast for
>   SIOCGETMIFCNT_IN6/SIOCGETSGCNT_IN6.
> 
> It would probably be a good idea if someone could complete the
> work on ipv4/v6 multicast compat_ioctl, on top of your patch.

Actually, on top of this, Eric's patch is buggy.

He defines the "struct compat_sioc_sg_req" but doesn't actually
use it.

I'll fix that, then take care of the missing cases.  Thanks Arnd.
