From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: sunvnet netdev ops conversion...
Date: Fri, 20 Mar 2009 01:34:48 -0700 (PDT)
Message-ID: <20090320.013448.251351318.davem@davemloft.net>
References: <20090320.005205.65922171.davem@davemloft.net>
	<49C35443.8020604@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42883
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757361AbZCTIfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 04:35:01 -0400
In-Reply-To: <49C35443.8020604@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Hongyang <yanghy@cn.fujitsu.com>
Date: Fri, 20 Mar 2009 16:30:59 +0800

> David Miller wrote:
> > Committed to net-next-2.6...
> > 
> > sunvnet: Convert to net_device_ops.
> 
> I noticed that there are other drivers's  net_device_ops 
> need to be converted,is these convert nessary?

Not necessary, but desirable.  Once all drivers are
converted we can remove the compatability code.
