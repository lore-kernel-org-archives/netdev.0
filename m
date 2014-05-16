From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvlan: simplify the structure port
Date: Thu, 15 May 2014 23:35:30 -0400 (EDT)
Message-ID: <20140515.233530.833461595757522176.davem@davemloft.net>
References: <5374A0E8.7070404@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbaEPDfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 23:35:31 -0400
In-Reply-To: <5374A0E8.7070404@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Thu, 15 May 2014 19:11:36 +0800

> The port->count was used to count the number of macvlan devs
> in the same port, but the list vlans could play the same role
> to do that, so free the port if the list vlans is empty and
> no need to use the parameter count.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied, thanks.
