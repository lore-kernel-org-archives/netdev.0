From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rtnetlink: ignore NETDEV_PRE_TYPE_CHANGE in
 rtnetlink_event()
Date: Sun, 21 Mar 2010 18:31:57 -0700 (PDT)
Message-ID: <20100321.183157.71563781.davem@davemloft.net>
References: <4BA38D50.4090909@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39746
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753646Ab0CVBbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 21:31:35 -0400
In-Reply-To: <4BA38D50.4090909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 19 Mar 2010 15:42:24 +0100

> Ignore the new NETDEV_PRE_TYPE_CHANGE event in rtnetlink_event() since
> there have been no changes userspace needs to be notified of.
> 
> Also add a comment to the netdev notifier event definitions to remind
> people to update the exclusion list when adding new event types.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
