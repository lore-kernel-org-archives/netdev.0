From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] s6gmac: Read buffer overflow
Date: Sun, 02 Aug 2009 12:31:35 -0700 (PDT)
Message-ID: <20090802.123135.184742883.davem@davemloft.net>
References: <4A75301D.5070802@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49075
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753394AbZHBTb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 15:31:27 -0400
In-Reply-To: <4A75301D.5070802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 02 Aug 2009 08:20:13 +0200

> Check whether index is within bounds before testing the element.
> In the last iteration i is PHY_MAX_ADDR. the condition
> `!(p = pd->mii.bus->phy_map[PHY_MAX_ADDR])' is undefined and may
> evaluate to false, which leads to a dereference of this invalid
> phy_map in the phy_connect() below.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
