From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 15:23:04 -0700 (PDT)
Message-ID: <20120627.152304.1739776707043296753.davem@davemloft.net>
References: <1340778733.2028.110.camel@localhost>
	<20120626.235423.588696200884989114.davem@davemloft.net>
	<20120627195032.GI1269@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, eric.dumazet@gmail.com,
	hans.schillstrom@ericsson.com, subramanian.vijay@gmail.com,
	dave.taht@gmail.com, netdev@vger.kernel.org, ncardwell@google.com,
	therbert@google.com, mph@hoth.dk
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768Ab2F0WXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 18:23:05 -0400
In-Reply-To: <20120627195032.GI1269@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 27 Jun 2012 21:50:32 +0200

> - we transmit hash result (i.e, its visible to 3rd party)

Indeed, that's right.
