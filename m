From: David Miller <davem@davemloft.net>
Subject: Re: NETLINK sockets dont honor SO_RCVLOWAT?
Date: Tue, 17 Nov 2009 23:17:06 -0800 (PST)
Message-ID: <20091117.231706.125598146.davem@davemloft.net>
References: <D67825C5985D0647BE40A5F5B0B70D1106E9C56894@HQ-EXCH-7.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jharan@Brocade.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43215
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752197AbZKRHQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 02:16:50 -0500
In-Reply-To: <D67825C5985D0647BE40A5F5B0B70D1106E9C56894@HQ-EXCH-7.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Haran <jharan@Brocade.COM>
Date: Tue, 17 Nov 2009 17:54:59 -0800

> Am I correct in my observation that the SO_RCVLOWAT socket option is
> not honored when one calls readv() on a PF_NETLINK socket?

That's correct.

SO_RCVLOWAT is only available on stream based sockets such as TCP and
UNIX.
