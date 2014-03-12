From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] tipc: simplifications in socket and port
 layer
Date: Wed, 12 Mar 2014 15:54:37 -0400 (EDT)
Message-ID: <20140312.155437.928020616843113075.davem@davemloft.net>
References: <1394638273-6127-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbaCLTyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 15:54:39 -0400
In-Reply-To: <1394638273-6127-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 12 Mar 2014 11:31:06 -0400

> After the removal of the tipc native API the relation between
> tipc_port and its API types is strictly one-to-one, i.e, the latter
> can now only be a socket API. This change opens up for
> simplifications both in the code, data and locking structure. 
> 
> We start with this series, where we ensure that port and socket
> structures are co-allocated. Note that the first commit in the
> series is unrelated to the above.

Series applied, thanks Jon.

I noticed one or two places where two empty lines were created between
functions, please only use one empty line to seperate functions in
the future.

Thanks.
