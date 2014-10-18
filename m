From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: fix bug in bundled buffer reception
Date: Fri, 17 Oct 2014 23:51:18 -0400 (EDT)
Message-ID: <20141017.235118.952173064143384619.davem@davemloft.net>
References: <1413573928-17954-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44362 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbaJRDvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 23:51:20 -0400
In-Reply-To: <1413573928-17954-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri, 17 Oct 2014 15:25:28 -0400

> In commit ec8a2e5621db2da24badb3969eda7fd359e1869f ("tipc: same receive
> code path for connection protocol and data messages") we omitted the
> the possiblilty that an arriving message extracted from a bundle buffer
> may be a multicast message. Such messages need to be to be delivered to
> the socket via a separate function, tipc_sk_mcast_rcv(). As a result,
> small multicast messages arriving as members of a bundle buffer will be
> silently dropped.
> 
> This commit corrects the error by considering this case in the function
> tipc_link_bundle_rcv().
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied and queued up for -stable.
