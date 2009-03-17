From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Multicast packet loss
Date: Tue, 17 Mar 2009 12:39:49 -0700
Message-ID: <OF37E3EF60.503CB684-ON8825757C.006B831D-8825757C.006C0301@us.ibm.com>
References: <49BFBEE4.9070405@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Brian Bloniarz <bmb@athenacr.com>, cl@linux-foundation.org,
	David Miller <davem@davemloft.net>, kchang@athenacr.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:41202 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096AbZCQTkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 15:40:00 -0400
In-Reply-To: <49BFBEE4.9070405@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did some testing with this and see at least a 20% improvement
without drop.

I agree with Peter's recommended changes (esp. sentinel vs null),
and also the trivial brace indentation  in softirq_delay_exec(),
but otherwise looks  good to me. Nice work.

                                        +-DLS

