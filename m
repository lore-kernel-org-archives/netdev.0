From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH -mm take4 6/6] add ioctls for adding/removing
 target
Date: Thu, 19 Apr 2007 23:59:08 -0700 (PDT)
Message-ID: <20070419.235908.122942095.davem@davemloft.net>
References: <46260BBF.2070202@bx.jp.nec.com>
	<20070419211630.70c20706.akpm@linux-foundation.org>
	<20070419223909.00e8285d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, k-keiichi@bx.jp.nec.com,
	mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54929
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753981AbXDTG7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 02:59:07 -0400
In-Reply-To: <20070419223909.00e8285d@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 19 Apr 2007 22:39:09 -0700

> Should't this just be a network ioctl against an UDP (AF_INET,
> SOCK_DGRAM) socket?  Also consider netconsole over IPV6 for future
> enhancement.

If it's on a socket use a socket option :-)
