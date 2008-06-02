From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [RFC v2 PATCH 1/3] net/core: add NETDEV_BONDING_FAILOVER event
Date: Mon, 2 Jun 2008 14:02:19 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0806021400220.31515@zuben.voltaire.com>
References: <Pine.LNX.4.64.0806021342120.31515@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:26947 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753205AbYFBLCU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 07:02:20 -0400
In-Reply-To: <Pine.LNX.4.64.0806021342120.31515@zuben.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Add NETDEV_BONDING_FAILOVER event to be used in a successive patch
> by bonding to announce fail-over for the active-backup mode through the
> netdev events notifier chain mechanism. Such an event can be of use for the
> RDMA CM (communication manager) to let native RDMA ULPs (eg NFS-RDMA, iSER)
> always be aligned with the IP stack, in the sense that they use the same
> ports/links as the stack does. More usages can be done to allow monitoring
> tools based on netlink events being aware to bonding fail-over.

The three patches were generated against and tested with the upstream-next
branch of Jeff's netdev-2.6 tree

Or.
