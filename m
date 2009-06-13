From: David Miller <davem@davemloft.net>
Subject: Re: net: use symbolic values for ndo_start_xmit() return codes
Date: Sat, 13 Jun 2009 01:19:41 -0700 (PDT)
Message-ID: <20090613.011941.261416607.davem@davemloft.net>
References: <4A3280C5.2090101@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50010
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750782AbZFMITj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 04:19:39 -0400
In-Reply-To: <4A3280C5.2090101@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 12 Jun 2009 18:22:29 +0200

> This is the final patch for now to get rid of invalid or magic return
> values in ndo_start_xmit() functions. There are no NETDEV_TX_OK
> conversions at this time to keep the noise down, but I wouldn't mind
> doing that as a final step at the end of the merge window.
> 
> I'll make a final pass over all the drivers before submitting
> the remaining patches.

I applied all of this to net-next-2.6 and am doing build testing
before I push it out to kernel.org

I highly encourage your NETDEV_TX_OK transformations. :-)
