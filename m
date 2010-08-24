From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Using GPU to do packet forwarding
Date: Tue, 24 Aug 2010 15:15:07 -0700
Message-ID: <20100824151507.5c13bd69@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32915 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932097Ab0HXWPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 18:15:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interesting paper:
  http://www.ndsl.kaist.edu/~kyoungsoo/papers/packetshader.pdf
One section of general consideration is the expense of the current
skb scheme. At 10G, they measure 60% of the CPU is used doing skb
alloc/free; see paper for the alternative of using a huge
packet buffer.  Also, they managed to shrink skb to 8 bytes!

