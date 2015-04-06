From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] bonding: cosmetic/readability changes for
 admin, oper-key ops
Date: Mon, 06 Apr 2015 17:01:06 -0400 (EDT)
Message-ID: <20150406.170106.811076629093466625.davem@davemloft.net>
References: <1428094440-9241-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com, maze@google.com, netdev@vger.kernel.org,
	edumazet@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48495 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752851AbbDFVBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 17:01:09 -0400
In-Reply-To: <1428094440-9241-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Fri,  3 Apr 2015 13:54:00 -0700

> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

This is a very low quality patch submission.

You aren't explaining what you are really doing, or why.

Furthermore:

> @@ -1756,8 +1758,6 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
>  		port->actor_system_priority = 0xffff;
>  		port->actor_port_aggregator_identifier = 0;
>  		port->ntt = false;
> -		port->actor_admin_port_key = 1;
> -		port->actor_oper_port_key  = 1;
>  		port->actor_admin_port_state = AD_STATE_AGGREGATION |
>  					       AD_STATE_LACP_ACTIVITY;
>  		port->actor_oper_port_state  = AD_STATE_AGGREGATION |

This is not just a readability or cosmetic change, it is changing behavior.

You need to describe why removing these initializers is valid, and also
this change is outside of the scope of a cosmetic/readability change so
would need to be split into another patch.

It is almost never correct to have an empty commit log message, espcially
when real changes are being made to the code as is happening here in this
code block.
