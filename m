From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: avoid reloads in SNMP_UPD_PO_STATS
Date: Mon, 06 Aug 2012 13:40:57 -0700 (PDT)
Message-ID: <20120806.134057.2007385552025196958.davem@davemloft.net>
References: <1344147973.9299.1563.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755991Ab2HFUk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 16:40:58 -0400
In-Reply-To: <1344147973.9299.1563.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 05 Aug 2012 08:26:13 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Avoid two instructions to reload dev->nd_net->mib.ip_statistics pointer,
> unsing a temp variable, in ip_rcv(), ip_output() paths for example.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied to net-next
