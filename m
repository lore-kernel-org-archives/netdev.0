From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] devinet: sysctl setup off by one
Date: Sun, 25 May 2008 22:51:38 -0700 (PDT)
Message-ID: <20080525.225138.46704597.davem@davemloft.net>
References: <20080523153559.156a1fb5@speedy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54819
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751141AbYEZFvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 01:51:42 -0400
In-Reply-To: <20080523153559.156a1fb5@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Fri, 23 May 2008 15:35:59 -0700

> It look like the code to setup /proc/sys/net/ipv4/conf/XXX has an
> off by one bug that causes the last entry (arp_accept) not to be
> adjusted properly.  This causes changes to the value to occur in the
> default namespace not the clone? Don't use network namespaces
> myself, but this looks like a bug.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Yikes, that is a very strange expression to be there by
accident.

Pavel, can you take a look at this?  Thanks.
