From: David Miller <davem@davemloft.net>
Subject: Re: Multiple TX queue implementation and Batching
Date: Thu, 19 Jun 2008 02:10:39 -0700 (PDT)
Message-ID: <20080619.021039.193704469.davem@davemloft.net>
References: <OF50454112.AA19F7EA-ON6525746D.002A115D-6525746D.002AD61A@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47302
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753370AbYFSJKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 05:10:39 -0400
In-Reply-To: <OF50454112.AA19F7EA-ON6525746D.002A115D-6525746D.002AD61A@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Thu, 19 Jun 2008 13:17:53 +0530

> Would it be possible to get a sneak preview of your multiple tx queue
> implementation (along with a complete re-write of the entire tx path)?
> 
> I would like to see if batching would make sense with the new design,
> or becomes redundant (or something to be done entirely at the drivers).

Right now I'm just hacking drivers in preparation for this, so
that the transmit queueing is seperated from the location
in the driver where this actually occurs.

I'll post a set of tg3 driver patches once I'm done debugging
things.
