From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: fix bug in multicast congestion
 handling
Date: Tue, 07 Oct 2014 13:07:51 -0400 (EDT)
Message-ID: <20141007.130751.1794928831124766854.davem@davemloft.net>
References: <1412698715-9838-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46501 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754453AbaJGRHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 13:07:54 -0400
In-Reply-To: <1412698715-9838-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Tue,  7 Oct 2014 12:18:35 -0400

> +	uint flags = node->action_flags;

Please use explicit "unsigned int"
