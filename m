From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/10] ipv4: Fetch values from flow key not route.
Date: Fri, 29 Apr 2011 10:26:47 -0700 (PDT)
Message-ID: <20110429.102647.226790886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52395
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757548Ab1D2R1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 13:27:20 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E313C24C087
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:26:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here is the first set of simplifications that are possible now that
output route lookup will update the flow lookup key the caller passes
in.

Signed-off-by: David S. Miller <davem@davemloft.net>
