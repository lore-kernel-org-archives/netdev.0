From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] bridge: don't change packet type
Date: Wed, 25 Apr 2007 22:05:17 -0700 (PDT)
Message-ID: <20070425.220517.62667709.davem@davemloft.net>
References: <20070425234737.727790594@linux-foundation.org>
	<20070425234950.610323798@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50459
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754444AbXDZFFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 01:05:10 -0400
In-Reply-To: <20070425234950.610323798@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 25 Apr 2007 16:47:38 -0700

> The change to forward STP bpdu's (for usermode STP) through normal path,
> changed the packet type in the process. Since link local stuff is multicast, it
> should stay pkt_type = PACKET_MULTICAST.  The code was probably copy/pasted
> incorrectly from the bridge pseudo-device receive path.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.

