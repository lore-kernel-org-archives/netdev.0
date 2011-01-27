From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/3] Put writable metrics in inetpeer cache
Date: Thu, 27 Jan 2011 15:00:34 -0800 (PST)
Message-ID: <20110127.150034.179937526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36913
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753803Ab1A0W77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 17:59:59 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6F72C24C089
	for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 15:00:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, this 3 patch set moves everything over, as planned.

The next patch series will implement the various optimizations I
mentioned last night (pre-COW for tcp, fib_info metrics external
storage with dst_default_metrics, and I've noticed some improvements
possible for IPSEC metrics too).
