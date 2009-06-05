From: Roland Dreier <rdreier@cisco.com>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Fri, 05 Jun 2009 09:54:09 -0700
Message-ID: <adaiqjawrim.fsf@cisco.com>
References: <alpine.DEB.1.10.0906021044430.15692@gentwo.org>
	<20090603.224104.222901210.davem@davemloft.net>
	<alpine.DEB.1.10.0906041150590.3204@gentwo.org>
	<20090604.153057.178458221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cl@linux-foundation.org, netdev@vger.kernel.org,
	yosefe@Voltaire.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:12482 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbZFEQyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 12:54:08 -0400
In-Reply-To: <20090604.153057.178458221.davem@davemloft.net> (David Miller's
	message of "Thu, 04 Jun 2009 15:30:57 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > Go look at what the ARP backlog queue actually does, then come back to
 > this conversation (hint: it's not a backlog for ARP packets, it's
 > a backlog for packets waiting for ARP to resolve).

Yes, I see now.  I confused myself a few times already in this
discussion.  I'm going to pull Christoph's patch out of my pending queue
for now until we reach agreement on this.

 - R.
