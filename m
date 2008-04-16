From: David Miller <davem@davemloft.net>
Subject: Re: netif_needs_gso behavior
Date: Wed, 16 Apr 2008 01:38:10 -0700 (PDT)
Message-ID: <20080416.013810.214799502.davem@davemloft.net>
References: <BAY121-W4698632384BFB6587EAB45B6EB0@phx.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bkostya@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45409
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754405AbYDPIiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 04:38:09 -0400
In-Reply-To: <BAY121-W4698632384BFB6587EAB45B6EB0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kostya B <bkostya@hotmail.com>
Date: Tue, 15 Apr 2008 16:52:20 +0000

> Please help me to understand why != CHECKSUM_PARTIAL packet requires gso? In the case of TCP it is ok, however UDP could be normally unchecked.

What exactly is the problem?  The UDP USO output paths set
CHECKSUM_PARTIAL just like the TCP TSO ones do, so the test will pass
for them.

