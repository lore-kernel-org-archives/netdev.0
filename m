From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove deprecated print_mac to fix warnings
Date: Sun, 06 Dec 2009 11:17:39 -0800 (PST)
Message-ID: <20091206.111739.40602157.davem@davemloft.net>
References: <20091206140828.GA8600@basil.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57645
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757207AbZLFTRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 14:17:34 -0500
In-Reply-To: <20091206140828.GA8600@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Sun, 6 Dec 2009 15:08:28 +0100

> Remove deprecated and unused print_mac to fix warnings
> 
> There seems to be no user in tree of print_mac left. So just remove it.
> 
> This eliminates two compiler warnings for every build, because gcc
> complains about the deprecated use of the symbol in its EXPORT_SYMBOL.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

davem@sunset:~/src/GIT/net-next-2.6$ git grep print_mac
davem@sunset:~/src/GIT/net-next-2.6$ 
