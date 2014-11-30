From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnetlink: release net refcnt on error in
 do_setlink()
Date: Sat, 29 Nov 2014 21:07:29 -0800 (PST)
Message-ID: <20141129.210729.1619791248311435624.davem@davemloft.net>
References: <1417079775-9287-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbaK3FDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 00:03:17 -0500
In-Reply-To: <1417079775-9287-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 27 Nov 2014 10:16:15 +0100

> rtnl_link_get_net() holds a reference on the 'struct net', we need to release
> it in case of error.
> 
> CC: Eric W. Biederman <ebiederm@xmission.com>
> Fixes: b51642f6d77b ("net: Enable a userns root rtnl calls that are safe for unprivilged users")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable, thanks.
