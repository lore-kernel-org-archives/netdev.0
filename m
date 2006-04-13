From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: via_rhine modules error on 2.6.16 with mii-tool
Date: Thu, 13 Apr 2006 23:36:34 +0200
Message-ID: <20060413213634.GA6769@electric-eye.fr.zoreil.com>
References: <BAY103-F401F96F0B06D75E70AF0BFB2DF0@phx.gbl> <20060327203946.GA11824@k3.hellgate.ch> <20060413182638.GC25854@tuxdriver.com> <20060413114018.65fba555@localhost.localdomain> <20060413204731.GB2874@k3.hellgate.ch> <20060413140252.1c22b078@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roger Luethi <rl@hellgate.ch>,
	"John W. Linville" <linville@tuxdriver.com>,
	Marco Berizzi <pupilla@hotmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57323 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S964978AbWDMVha
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 17:37:30 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060413140252.1c22b078@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> The other drivers should be fixed as well.  Phy access with irq's disabled
> is not good. The hardware I checked takes 100's of usecs to do one read
> transaction.

Yep, 802.3 allows it. :o|

It's surprizing that the low latency squadron has not complained so far
from our bad habit of spinlocked, irq disabled, MII access.

-- 
Ueimor
