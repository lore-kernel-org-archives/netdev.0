From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Mon, 06 Jun 2011 13:23:15 -0700 (PDT)
Message-ID: <20110606.132315.1222364671200899036.davem@davemloft.net>
References: <201106062206.29134.arnd@arndb.de>
	<20110606.130958.1488166895702555231.davem@davemloft.net>
	<201106062219.33432.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55562 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613Ab1FFUXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:23:21 -0400
In-Reply-To: <201106062219.33432.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 6 Jun 2011 22:19:33 +0200

> I think it would be good to first understand why it doesn't work with the
> new style ioctls that are in the kernel. The source code of brctl that
> I'm looking at here contains:

Eric's 32-bit binary was built against older headers that didn't
define the new ioctls.

That makes it pretty clear to me that we have to support those
older ioctls in compat mode even after all these years.
