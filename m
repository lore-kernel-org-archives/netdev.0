From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Add/Delete IPv6 addresses and netlink
Date: Tue, 17 Jun 2008 14:18:21 +0200
Message-ID: <20080617121821.GC20815@postel.suug.ch>
References: <48571470.7010307@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:60488 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753856AbYFQMSB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 08:18:01 -0400
Content-Disposition: inline
In-Reply-To: <48571470.7010307@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ben Greear <greearb@candelatech.com> 2008-06-16 18:33
> I am not sure whether I am just confused about how all of this is 
> supposed to work or not, but the
> following commands will leave the global address in tentative state:
> 
> ip link set eth1 down; ip -6 addr flush dev eth1;
> ip -6 addr add 2000::9:2/112 scope global dev eth1
> ip link set eth1 up
> # Wait 10+ seconds
> ip -6 addr show dev eth1
> 3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
>    inet6 2000::9:2/112 scope global tentative
>       valid_lft forever preferred_lft forever
>    inet6 fe80::203:2dff:fe0c:d022/64 scope link
>       valid_lft forever preferred_lft forever

Do you see a "ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready"
message in the console when you up the device?
