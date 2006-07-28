From: David Miller <davem@davemloft.net>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Thu, 27 Jul 2006 19:27:43 -0700 (PDT)
Message-ID: <20060727.192743.39159331.davem@davemloft.net>
References: <E1G6Fic-0005py-00@gondolin.me.apana.org.au>
	<20060727.183415.104032934.davem@davemloft.net>
	<20060728014528.GB29313@innerghost.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kazunori@miyazawa.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48334
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932571AbWG1C17 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 22:27:59 -0400
To: hsantos@av.it.pt
In-Reply-To: <20060728014528.GB29313@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hugo Santos <hsantos@av.it.pt>
Date: Fri, 28 Jul 2006 02:45:28 +0100

>   Is it reasonable to consider that control packet processing needs to
> be serialized with data packet processing? In this particular case, is
> it not the tests that are broken if not giving enough time to the host
> to configure the address? The standards do not specify implementation
> details so no specific processing model should be assumed, and what you
> describe sounds a bit like an ideal model.

Just like a TCP connection, packets cause state transitions.
And it is reasonable to expect that after a state transition,
the effects can be visible by subsequent packets.

I think the tests are doing valid things.
