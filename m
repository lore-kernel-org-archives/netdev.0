From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] bridge: simpler hash with salt
Date: Tue, 27 Mar 2007 19:17:56 -0700 (PDT)
Message-ID: <20070327.191756.78707233.davem@davemloft.net>
References: <20070320141251.3760d87f@dxpl.pdx.osdl.net>
	<20070320141709.4ebb79ec@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44593
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932231AbXC1CR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 22:17:57 -0400
In-Reply-To: <20070320141709.4ebb79ec@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 20 Mar 2007 14:17:09 -0700

> Instead of hashing the whole Ethernet address, it should be faster
> to just use the last 4 bytes. Add a random salt value to the hash
> to make it more difficult to construct worst case DoS hash chains.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied to net-2.6.22
