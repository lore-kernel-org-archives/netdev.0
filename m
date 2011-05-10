From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/10] Another batch of rt->rt_{src,dst} removals
Date: Mon, 09 May 2011 22:31:08 -0700 (PDT)
Message-ID: <20110509.223108.39186087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53391
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751546Ab1EJFbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 01:31:40 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8360224C087
	for <netdev@vger.kernel.org>; Mon,  9 May 2011 22:31:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After this series there are very nearly no references remaining
outside of net/ipv4/route.c

They all come in the usual pattern, making sure the flow key can be
materialized at the site where rt->rt_{src,dst} is needed.

Signed-off-by: David S. Miller <davem@davemloft.net>
