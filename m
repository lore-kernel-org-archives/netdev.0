From: David Miller <davem@davemloft.net>
Subject: Re: sumgem problems with initializiation order at a 1000SX SERDES
 card [experimental patch]
Date: Mon, 01 Dec 2008 23:35:39 -0800 (PST)
Message-ID: <20081201.233539.77173438.davem@davemloft.net>
References: <20081125103029.GD12605@lemon.iwr.uni-heidelberg.de>
	<20081126.011809.241693537.davem@davemloft.net>
	<20081128000059.GA13712@lemon.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hermann.Lauer@iwr.uni-heidelberg.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45004
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751064AbYLBHfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 02:35:39 -0500
In-Reply-To: <20081128000059.GA13712@lemon.iwr.uni-heidelberg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hermann Lauer <Hermann.Lauer@iwr.uni-heidelberg.de>
Date: Fri, 28 Nov 2008 01:00:59 +0100

> Attached is an experimental patch which made my 1000SX sungem card (with phy_serdes) working.
> As suspected, reinitialising the PCS part after the global reset in gem_reinit_chip()
> gets autonegotiation working and the link is established also after an ifconfig up
> command now. Access through the card did not show any errors so far.
> 
> Will try to add the missing if clauses to the patch as time allows me, comments are welcome.

Thanks a lot for doing this work and tracking down the problem.

I'll take a look at your patch as soon as I can.

Thanks again.
