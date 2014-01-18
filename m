From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: send Change Status Report after DAD is
 completed
Date: Fri, 17 Jan 2014 18:13:02 -0800 (PST)
Message-ID: <20140117.181302.133848771524238969.davem@davemloft.net>
References: <1389907679-15346-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	hannes@stressinduktion.org
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbaARCNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 21:13:02 -0500
In-Reply-To: <1389907679-15346-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Thu, 16 Jan 2014 19:27:59 -0200

> The RFC 3810 defines two type of messages for multicast
> listeners. The "Current State Report" message, as the name
> implies, refreshes the *current* state to the querier.
> Since the querier sends Query messages periodically, there
> is no need to retransmit the report.
> 
> On the other hand, any change should be reported immediately
> using "State Change Report" messages. Since it's an event
> triggered by a change and that it can be affected by packet
> loss, the rfc states it should be retransmitted [RobVar] times
> to make sure routers will receive timely.
> 
> Currently, we are sending "Current State Reports" after
> DAD is completed.  Before that, we send messages using
> unspecified address (::) which should be silently discarded
> by routers.
> 
> This patch changes to send "State Change Report" messages
> after DAD is completed fixing the behavior to be RFC compliant
> and also to pass TAHI IPv6 testsuite.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

Applied.
