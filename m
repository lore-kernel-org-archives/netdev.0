From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6_tunnel: set rtnl_link_ops before calling
 register_netdevice
Date: Tue, 05 Apr 2016 19:49:28 -0400 (EDT)
Message-ID: <20160405.194928.376989558067711341.davem@davemloft.net>
References: <1459541870-26938-1-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cascardo@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35049 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760287AbcDEXtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 19:49:31 -0400
In-Reply-To: <1459541870-26938-1-git-send-email-cascardo@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Date: Fri,  1 Apr 2016 17:17:50 -0300

> When creating an ip6tnl tunnel with ip tunnel, rtnl_link_ops is not set
> before ip6_tnl_create2 is called. When register_netdevice is called, there
> is no linkinfo attribute in the NEWLINK message because of that.
> 
> Setting rtnl_link_ops before calling register_netdevice fixes that.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>

Applied and queued up for -stable.
