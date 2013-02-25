From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove the unnecessary list_del
Date: Sun, 24 Feb 2013 23:54:11 -0500 (EST)
Message-ID: <20130224.235411.1871885689914104471.davem@davemloft.net>
References: <1361767316-28583-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759567Ab3BYEyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 23:54:15 -0500
In-Reply-To: <1361767316-28583-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Mon, 25 Feb 2013 12:41:56 +0800

> These lists are used by unregister_netdevice_many,
> they are local variables,will not be seen by others.
> there is no need to delete them.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

What about the devices on the list?  The ones at the front and the
rear of the list will have list pointers that point into no longer
valid stack frame locations.
