From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 01:13:53 -0700 (PDT)
Message-ID: <20120627.011353.1579082129809057643.davem@davemloft.net>
References: <20120626.235423.588696200884989114.davem@davemloft.net>
	<1340781845.2028.133.camel@localhost>
	<1340782216.10893.427.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, hans.schillstrom@ericsson.com,
	subramanian.vijay@gmail.com, dave.taht@gmail.com,
	netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	mph@hoth.dk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756138Ab2F0IOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:14:00 -0400
In-Reply-To: <1340782216.10893.427.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Jun 2012 09:30:16 +0200

> Many linux servers in colocations are still using a mono queue NIC, and
> default linux configuration is to use a single cpu to handle all
> incoming frames (no RPS/RFS).

Even worse, many are virtualized guest with single virtual netdev
queue :-)
