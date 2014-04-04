From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] veth: keep peers MTU values synchronized
Date: Fri, 04 Apr 2014 10:25:18 -0400 (EDT)
Message-ID: <20140404.102518.2263545144702348056.davem@davemloft.net>
References: <533DD390.6020103@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, i.matveychikov@securitycode.ru
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314AbaDDOXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 10:23:50 -0400
In-Reply-To: <533DD390.6020103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ilya V. Matveychikov" <matvejchikov@gmail.com>
Date: Fri, 04 Apr 2014 01:33:04 +0400

> Keep peers MTU values synchronized. That prevent dropping packets
> while
> forwarding as diffirent MTU values prevent skb moving from one peer's
> device to another (is_skb_forwardable returns false).
> 
> Signed-off-by: Ilya V. Matveychikov <i.matveychikov@securitycode.ru>

Such side effects on another device when changing the configuration
of one are strongly discouraged.

Furthermore, when the veth peer is created, no attempt is made to
synchronize the MTUs.

Let it therefore be the admins responsibility to keep them in sync
just as it would be on a real network.
