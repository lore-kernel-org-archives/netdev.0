From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sctp: Don't transition to PF state when transport
 has exhausted 'Path.Max.Retrans'.
Date: Tue, 27 May 2014 16:03:10 -0400 (EDT)
Message-ID: <20140527.160310.1480565548591849457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org
To: kheiss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbaE0UDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 16:03:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If you guys want me to submit this for -stable releases v3.10 and earlier
I'll need someone knowledgable with this code to do the backport(s) as
this change doesn't come close to applying.

In particular, in v3.10 the (transport->state != SCTP_UNCONFIRMED) part of
the test isn't even there.

Thanks.
