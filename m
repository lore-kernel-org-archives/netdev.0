From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 02 Jun 2010 08:29:13 -0700 (PDT)
Message-ID: <20100602.082913.77341581.davem@davemloft.net>
References: <alpine.DEB.2.00.1006011609280.9438@router.home>
	<1275430054.2638.115.camel@edumazet-laptop>
	<alpine.DEB.2.00.1006021025200.30182@router.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39560
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758415Ab0FBP3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 11:29:04 -0400
In-Reply-To: <alpine.DEB.2.00.1006021025200.30182@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 2 Jun 2010 10:27:13 -0500 (CDT)

> LINUX_MIB_INROUTEERRORS? Does it mean I can create a series of new
> counters that allow us to diagnose and distinguish all the different
> causes of packet loss? We would love to have that.

Within reason.

If you're going to spam the tree with something like 10 or 20 new
stat counters getting bumped all over the place, that's not what
we're trying to suggest here.

Consolidate as much as possible, add new things when absolutely
nothing existing fits the bill.
