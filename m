From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 05/14] tipc: remove 'links' list from
 tipc_bearer struct
Date: Wed, 12 Feb 2014 19:00:56 -0500 (EST)
Message-ID: <20140212.190056.911642661418186134.davem@davemloft.net>
References: <1392229874-29675-1-git-send-email-jon.maloy@ericsson.com>
	<1392229874-29675-6-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbaBMAA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 19:00:58 -0500
In-Reply-To: <1392229874-29675-6-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 12 Feb 2014 13:31:05 -0500

> @@ -146,12 +146,6 @@ int tipc_link_is_active(struct tipc_link *l_ptr)
>  
>  /**
>   * link_timeout - handle expiration of link timer
> - * @l_ptr: pointer to link
> - *
> - * This routine must not grab "tipc_net_lock" to avoid a potential deadlock conflict
> - * with tipc_link_delete().  (There is no risk that the node will be deleted by
> - * another thread because tipc_link_delete() always cancels the link timer before
> - * tipc_node_delete() is called.)
>   */
>  static void link_timeout(struct tipc_link *l_ptr)
>  {

There is no reason to remove the kerneldoc entry for @l_ptr in this comment,
the argument is still there.
