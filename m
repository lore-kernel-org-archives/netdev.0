From: David Miller <davem@davemloft.net>
Subject: [PATCH 00/20] Const'ify flowi args in xfrm and flow cache.
Date: Tue, 22 Feb 2011 19:54:05 -0800 (PST)
Message-ID: <20110222.195405.193690177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32811
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755683Ab1BWDxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:53:30 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8C48424C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:54:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This series walks the dependency chain marking flowi arguments
as const, when possible, in the xfrm layer.

Then at the end we are able to thus use const flowi objects in
the flow cache as well.

Signed-off-by: David S. Miller <davem@davemloft.net>
