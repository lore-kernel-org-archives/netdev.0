From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tipc: fix handling of NETDEV_CHANGEADDR
 event
Date: Fri, 28 Mar 2014 14:46:59 -0400 (EDT)
Message-ID: <20140328.144659.1159122269415391627.davem@davemloft.net>
References: <1395999129-31688-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com,
	paul.gortmaker@windriver.com, richard.alpe@ericsson.com,
	aleksandar.igic@dektech.com.au
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39660 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbaC1SrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 14:47:03 -0400
In-Reply-To: <1395999129-31688-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Fri, 28 Mar 2014 10:32:07 +0100

> Aside from manual reconfiguration of the netdevice hwaddr, this can also
> be changed automatically for an interface bond in active-backup mode
> if fail_over_mac is enabled. This patchset fixes the handling of this
> event in TIPC by properly updating the l2 media address for the bearer,
> followed by a reinitialization of the node discovery mechanism.

Series applied, thank you.
