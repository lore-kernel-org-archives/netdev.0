From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/5] tipc: fix nullpointer bug when
 subscribing to events
Date: Thu, 26 Feb 2015 11:20:09 -0500 (EST)
Message-ID: <20150226.112009.1387286126679105800.davem@davemloft.net>
References: <1424933010-31003-1-git-send-email-erik.hugne@ericsson.com>
	<1424933010-31003-3-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbbBZQUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 11:20:14 -0500
In-Reply-To: <1424933010-31003-3-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Thu, 26 Feb 2015 07:43:27 +0100

> @@ -312,16 +299,15 @@ static void subscr_conn_msg_event(struct net *net, int conid,
>  {
>  	struct tipc_subscriber *subscriber = usr_data;
>  	struct tipc_subscription *sub = NULL;
> +	struct tipc_net *tn = net_generic(net, tipc_net_id);
> +
>  
>  	spin_lock_bh(&subscriber->lock);

Please only have one empty line between local variable declarations
and code.
