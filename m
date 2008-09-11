From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/3]: Put DMA cookies into skb_shared_info().
Date: Thu, 11 Sep 2008 05:03:03 -0700 (PDT)
Message-ID: <20080911.050303.193692952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56513
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752570AbYIKMDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 08:03:09 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6F994C8C181
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 05:03:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In order to facilitate several things, including some software
GSO hacks Herbert and I want to do, these patches add DMA address
cookies into the SKB shared data area.

The first patch adjusts the datastructures.

The second one adds some DMA mapping helpers that drivers can
use.

The third patch converts tg3 as a proof of concept.
