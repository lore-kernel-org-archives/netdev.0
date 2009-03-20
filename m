From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]spider_net:remove '&' in the init of function pointers
Date: Fri, 20 Mar 2009 01:21:52 -0700 (PDT)
Message-ID: <20090320.012152.95177338.davem@davemloft.net>
References: <49C3515D.7090703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jens@de.ibm.com, kou.ishizaki@toshiba.co.jp, netdev@vger.kernel.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38382
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750979AbZCTIWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 04:22:05 -0400
In-Reply-To: <49C3515D.7090703@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Hongyang <yanghy@cn.fujitsu.com>
Date: Fri, 20 Mar 2009 16:18:37 +0800

> Do not need '&' in the init of function pointers.
> 
> Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com>

It's harmless, just leave it alone.  This is just going to be commit
noise.

More useful would be to convert this driver over to net_device_ops.

I'm not applying this.
