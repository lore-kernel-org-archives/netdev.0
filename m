From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 04/04]: Eliminate qdisc_tree_lock
Date: Mon, 16 Apr 2007 17:06:16 -0700 (PDT)
Message-ID: <20070416.170616.01051501.davem@davemloft.net>
References: <20070416074949.19262.73702.sendpatchset@localhost.localdomain>
	<20070416074954.19262.99623.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58433
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754076AbXDQAGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 20:06:14 -0400
In-Reply-To: <20070416074954.19262.99623.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 16 Apr 2007 09:51:57 +0200 (MEST)

> [NET_SCHED]: Eliminate qdisc_tree_lock
> 
> Since we're now holding the rtnl during the entire dump operation, we
> can remove qdisc_tree_lock, whose only purpose is to protect dump
> callbacks from concurrent changes to the qdisc tree.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Also applied, thanks a lot Patrick.
