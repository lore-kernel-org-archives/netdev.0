From: David Miller <davem@davemloft.net>
Subject: Re: Adding inode field to /proc/net/netlink
Date: Sun, 28 Feb 2010 01:00:57 -0800 (PST)
Message-ID: <20100228.010057.229746532.davem@davemloft.net>
References: <20100228.144537.445518512048328806.yamato@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yamato@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42616
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031632Ab0B1JAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 04:00:39 -0500
In-Reply-To: <20100228.144537.445518512048328806.yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masatake YAMATO <yamato@redhat.com>
Date: Sun, 28 Feb 2010 14:45:37 +0900 (JST)

> The Inode field in /proc/net/{tcp,udp,packet,raw,...} is useful to know the types of 
> file descriptors associated to a process. Actually lsof utility uses the field.
> Unfortunately, unlike /proc/net/{tcp,udp,packet,raw,...}, /proc/net/netlink doesn't have the field.
> This patch adds the field to /proc/net/netlink.
> 
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>

Unfortunately we cannot add new fields without breaking the parsing
done by existing applications.

Sorry.
