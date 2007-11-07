From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [AF_PACKET]: Allow multicast traffic to be caught by
 ORIGDEV when bonded
Date: Wed, 07 Nov 2007 02:21:16 -0800 (PST)
Message-ID: <20071107.022116.16986000.davem@davemloft.net>
References: <20071106152547.14672.10821.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58550
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751382AbXKGKVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 05:21:17 -0500
In-Reply-To: <20071106152547.14672.10821.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Date: Tue, 06 Nov 2007 07:25:47 -0800

> The socket option for packet sockets to return the original ifindex instead
> of the bonded ifindex will not match multicast traffic.  Since this socket
> option is the most useful for layer 2 traffic and multicast traffic, make
> the option multicast-aware.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

I agree with you in principle, but I'd like to hear some feedback
from other folks.  In particular I'd like a discussion about
what this might break, if anything.
