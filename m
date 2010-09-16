From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/18] i4l: kill big kernel lock
Date: Wed, 15 Sep 2010 19:31:31 -0700 (PDT)
Message-ID: <20100915.193131.108799689.davem@davemloft.net>
References: <1284492909-7147-1-git-send-email-arnd@arndb.de>
	<1284492909-7147-14-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58343
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753217Ab0IPCbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 22:31:13 -0400
In-Reply-To: <1284492909-7147-14-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 14 Sep 2010 21:35:04 +0200

> The isdn4linux driver uses the big kernel lock only
> to serialize access to a few fields in its own
> modem_info structure.
> 
> The easiest replacement is a driver-wide mutex.
> More fine-grained locking would be more appropriate
> here, but likely harder to implement.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
