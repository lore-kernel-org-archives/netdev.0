From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2] Get flow key down into ipv4 datagram packet engine
Date: Sun, 08 May 2011 18:07:51 -0700 (PDT)
Message-ID: <20110508.180751.191383672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54399
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756285Ab1EIBIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 21:08:24 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 14E1724C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 18:07:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The really nice part about this patch set is that it will subsequently
allow us to kill a lot of on-stack stuff.

Parts of what we pass around in the flow key is also passed around in
this "ipcm_cookie" object we use for datagram/raw/icmp packet
construction.

So now we can perform some minimizations on ipcm_cookie as a result.
