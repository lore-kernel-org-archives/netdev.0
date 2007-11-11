From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [AF_PACKET]: Allow multicast traffic to be caught by
 ORIGDEV when bonded
Date: Sat, 10 Nov 2007 22:03:40 -0800 (PST)
Message-ID: <20071110.220340.221098168.davem@davemloft.net>
References: <20071106152547.14672.10821.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47594
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751494AbXKKGDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 01:03:41 -0500
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

Applied, thanks Peter.
