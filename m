From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: mark link down on startup and let PHY
 interrupt deal with carrier changes
Date: Tue, 24 Apr 2012 00:25:30 -0400 (EDT)
Message-ID: <20120424.002530.64732260146351305.davem@davemloft.net>
References: <1334914521-5990-1-git-send-email-paolo.pisati@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com
To: paolo.pisati@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35233 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959Ab2DXEZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 00:25:37 -0400
In-Reply-To: <1334914521-5990-1-git-send-email-paolo.pisati@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Pisati <paolo.pisati@canonical.com>
Date: Fri, 20 Apr 2012 11:35:21 +0200

> Without this patch sysfs reports the cable as present
> 
> flag@flag-desktop:~$ cat /sys/class/net/eth0/carrier
> 1
> 
> while it's not:
> 
> flag@flag-desktop:~$ sudo mii-tool eth0
> eth0: no link
> 
> Signed-off-by: Paolo Pisati <paolo.pisati@canonical.com>

I suspect Steve didn't set the FLAG_LINK_INTR bit intentionally, and
that the link status IRQ is not reliable on all smsc95xx chips.

Steve?
