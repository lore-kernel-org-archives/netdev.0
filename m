From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netconsole: avoid null pointer dereference at
 show_local_mac()
Date: Fri, 15 Feb 2008 02:02:12 -0800 (PST)
Message-ID: <20080215.020212.202401321.davem@davemloft.net>
References: <47B55F4C.5080703@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, satyam.sharma@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: k-keiichi@bx.jp.nec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45249
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754593AbYBOKBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 05:01:42 -0500
In-Reply-To: <47B55F4C.5080703@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Date: Fri, 15 Feb 2008 18:45:48 +0900

> This patch avoids a null pointer dereference when we read local_mac 
> for netconsole in configfs and shows default local mac address
> value.
> 
> A null pointer dereference occurs when we call show_local_mac() via 
> local_mac entry in configfs before we setup the content of netpoll
> using netpoll_setup().
> 
> This patch is for 2.6.25-rc1.
> Your comments are very welcome.
> 
> Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>

Patch applied, thank you.
