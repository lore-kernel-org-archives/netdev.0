From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Tue, 26 Jun 2012 23:54:23 -0700 (PDT)
Message-ID: <20120626.235423.588696200884989114.davem@davemloft.net>
References: <201206260734.33472.hans.schillstrom@ericsson.com>
	<1340730156.10893.359.camel@edumazet-glaptop>
	<1340778733.2028.110.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hans.schillstrom@ericsson.com,
	subramanian.vijay@gmail.com, dave.taht@gmail.com,
	netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	mph@hoth.dk
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab2F0Gy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 02:54:26 -0400
In-Reply-To: <1340778733.2028.110.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 27 Jun 2012 08:32:13 +0200

> Using it as default, might be "dangerous" and open an attack vector
> on SYN cookies in Linux.

If it's dangerous for syncookies then it's just as dangerous for
the routing hash and the socket hashes where we use it already.

Therefore, this sounds like a baseless claim to me.
