From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Initialize entire flowi struct
Date: Wed, 31 Aug 2011 16:47:29 -0400 (EDT)
Message-ID: <20110831.164729.2008828559026927348.davem@davemloft.net>
References: <1314806703-5275-1-git-send-email-david.ward@ll.mit.edu>
	<alpine.LFD.2.00.1108312321400.1826@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.ward@ll.mit.edu, netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930Ab1HaUrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 16:47:45 -0400
In-Reply-To: <alpine.LFD.2.00.1108312321400.1826@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 31 Aug 2011 23:51:32 +0300 (EEST)

> 	Such change will cause problems for callers that
> use flowi4 in stack. Examples:
> 
> ip_route_me_harder
> icmp_route_lookup

Right.
