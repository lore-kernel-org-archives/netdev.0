From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] tipc: resolve message disordering problem
Date: Thu, 05 Feb 2015 16:00:35 -0800 (PST)
Message-ID: <20150205.160035.485906710491477883.davem@davemloft.net>
References: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbbBFAAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 19:00:36 -0500
In-Reply-To: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu,  5 Feb 2015 08:36:35 -0500

> When TIPC receives messages from multi-threaded device drivers it may
> occasionally deliver messages to their destination sockets in the wrong
> order. This happens despite correct resequencing at the link layer,
> because the upcall path from link to socket is not protected by any
> locks.
> 
> These commits solve this problem by introducing an 'input' message
> queue in each link, through which messages must be delivered to the
> upper layers.

Looks good, series applied, thanks Jon.
