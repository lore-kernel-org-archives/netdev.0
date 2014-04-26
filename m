From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] tipc: add support for link state
 subscriptions
Date: Sat, 26 Apr 2014 12:13:55 -0400 (EDT)
Message-ID: <20140426.121355.2287323378064995557.davem@davemloft.net>
References: <1398349607-16012-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com,
	paul.gortmaker@windriver.com, richard.alpe@ericsson.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbaDZQOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 12:14:00 -0400
In-Reply-To: <1398349607-16012-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Thu, 24 Apr 2014 16:26:45 +0200

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> Low level topology information like TIPC link up/down is useful for
> applications like teamd to make smarter failover decisions in a
> HA cluster environment. Fetching logical link names through an ioctl
> may hurt the eyes of some. Suggestions for a more elegant way of doing
> this would be appreciated in that case. :)
> 
> v2: 
>    -Properly based on net-next
>    -Off-list comments from Billie Alsup:
>     -Add a string length parameter to tipc_node_get_linkname
>     -Use TIPC_MAX_LINK_NAME definition instead of hardcoded
>      value in tipc_sioc_ln_req linkname

Series applied, thanks.
