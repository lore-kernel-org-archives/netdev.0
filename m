From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] bonding: reread information about
 speed and duplex when interface goes up
Date: Wed, 06 Oct 2010 14:28:31 -0700 (PDT)
Message-ID: <20101006.142831.102541368.davem@davemloft.net>
References: <4ca4b87e.NzbQ35P2qRrA2iuz%ole@ans.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: ole@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33931
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756156Ab0JFV2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 17:28:10 -0400
In-Reply-To: <4ca4b87e.NzbQ35P2qRrA2iuz%ole@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Piotr Oledzki <ole@ans.pl>
Date: Thu, 30 Sep 2010 18:19:10 +0200

>>From 43285224a785e90c7d4cff2be0766ca8df6ddfb9 Mon Sep 17 00:00:00 2001
> From: Krzysztof Piotr Oledzki <ole@ans.pl>
> Date: Thu, 30 Sep 2010 17:09:02 +0200
> Subject: bonding: reread information about speed and duplex when interface goes up
> 
> When an interface was enslaved when it was down, bonding thinks
> it has speed -1 even after it goes up. This leads into selecting
> a wrong active interface in active/backup mode on mixed 10G/1G or
> 1G/100M environment.
> 
> before:
>  bonding: bond0: link status definitely up for interface eth5, 100 Mbps full duplex.
>  bonding: bond0: link status definitely up for interface eth0, 100 Mbps full duplex.
> 
> after:
>  bonding: bond0: link status definitely up for interface eth5, 10000 Mbps full duplex.
>  bonding: bond0: link status definitely up for interface eth0, 1000 Mbps full duplex.
> 
> Signed-off-by: Krzysztof Piotr Oledzki <ole@ans.pl>

Applied.
