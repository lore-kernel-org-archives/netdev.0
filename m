From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ndo_fdb_dump should report -EMSGSIZE to
 rtnl_fdb_dump.
Date: Fri, 26 Feb 2016 15:04:58 -0500 (EST)
Message-ID: <20160226.150458.1711282575316157924.davem@davemloft.net>
References: <kk537sh1i33.fsf@brer.local.valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: minoura@valinux.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbcBZUFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 15:05:00 -0500
In-Reply-To: <kk537sh1i33.fsf@brer.local.valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: MINOURA Makoto / 箕浦 真 <minoura@valinux.co.jp>
Date: Thu, 25 Feb 2016 14:20:48 +0900

> When the send skbuff reaches the end, nlmsg_put and friends returns
> -EMSGSIZE but it is silently thrown away in ndo_fdb_dump. It is called
> within a for_each_netdev loop and the first fdb entry of a following
> netdev could fit in the remaining skbuff.  This breaks the mechanism
> of cb->args[0] and idx to keep track of the entries that are already
> dumped, which results missing entries in bridge fdb show command.
> 
> Signed-off-by: Minoura Makoto <minoura@valinux.co.jp>

Good catch, applied, thanks.
