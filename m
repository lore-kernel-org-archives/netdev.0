From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sit: set rtnl_link_ops before calling
 register_netdevice
Date: Mon, 25 Jan 2016 10:53:02 -0800 (PST)
Message-ID: <20160125.105302.658707800815766292.davem@davemloft.net>
References: <1453728559-4903-1-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cascardo@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49164 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757539AbcAYSxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 13:53:02 -0500
In-Reply-To: <1453728559-4903-1-git-send-email-cascardo@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Date: Mon, 25 Jan 2016 11:29:19 -0200

> When creating a SIT tunnel with ip tunnel, rtnl_link_ops is not set before
> ipip6_tunnel_create is called. When register_netdevice is called, there is
> no linkinfo attribute in the NEWLINK message because of that.
> 
> Setting rtnl_link_ops before calling register_netdevice fixes that.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>

Applied.
