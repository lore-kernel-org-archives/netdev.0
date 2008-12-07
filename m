From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] s390_net: Kill directly reference of netdev->priv
Date: Sat, 06 Dec 2008 23:58:00 -0800 (PST)
Message-ID: <20081206.235800.238700098.davem@davemloft.net>
References: <49394443.1020402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	linux390@de.ibm.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59412
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752839AbYLGH57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2008 02:57:59 -0500
In-Reply-To: <49394443.1020402@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 05 Dec 2008 23:09:55 +0800

> The private data comes from ccwgroup_device.
> So just don't allocate private data memory when do alloc_netdev()
> and use netdev->ml_priv to reference private data.
> 
> Not do compile-test. Because have no s390 box.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied, thanks Wang.
