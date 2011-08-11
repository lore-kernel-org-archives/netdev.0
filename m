From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] tcp: Replace possible syn attack msg by counters
Date: Wed, 10 Aug 2011 23:13:18 -0700 (PDT)
Message-ID: <20110810.231318.959972077845910551.davem@davemloft.net>
References: <alpine.DEB.2.00.1108102229130.5341@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674Ab1HKGNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 02:13:22 -0400
In-Reply-To: <alpine.DEB.2.00.1108102229130.5341@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 10 Aug 2011 22:38:02 -0700 (PDT)

> Rather than printing the message to the log, use a mib counter to keep
> track of the count of occurences of syn cookies being used or syn
> being dropped when request queue is full.
> 
> Rationale is these messages can fill up /var/log/messages on server
> which is simply under heavy load... I'm not sure how much more useful
> they would be in identifying a server DOS attack (compared to
> counters).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Print the message once, and also do the counters.

Say something like "Possible SYN flooding, see SNMP counters." or
similar.

Because if people are grepping for that message in their logs, they
will now have a false sense of confidence seeing it not being there
any more.
