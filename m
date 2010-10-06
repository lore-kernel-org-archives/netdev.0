From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] bonding: add Speed/Duplex information
 to /proc/net/bonding/bond
Date: Wed, 06 Oct 2010 14:24:24 -0700 (PDT)
Message-ID: <20101006.142424.246555203.davem@davemloft.net>
References: <4ca4b878.KGc4gLtXHLSFlAdV%ole@ans.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: ole@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45586
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933092Ab0JFVYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 17:24:03 -0400
In-Reply-To: <4ca4b878.KGc4gLtXHLSFlAdV%ole@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Piotr Oledzki <ole@ans.pl>
Date: Thu, 30 Sep 2010 18:19:04 +0200

> Subject: bonding: add Speed/Duplex information to /proc/net/bonding/bond*
> 
> Effect:
>  Slave Interface: eth5
>  MII Status: up
>  Speed: 10000 Mbps
>  Duplex: full
>  Link Failure Count: 0
>  Permanent HW addr: XX:XX:XX:XX:XX:XX
>  Slave queue ID: 0
> 
> Signed-off-by: Krzysztof Piotr Oledzki <ole@ans.pl>

Changing the layout of a procfs file is pretty much always unsafe.

Some useland program somewhere depends upon the current layout, and
therefore very likely could break if we change the contents.

We really can't apply a patch like this.  A most portable and
extensible interface (netlink, ethtool) should be used to provide this
information to userspace.
