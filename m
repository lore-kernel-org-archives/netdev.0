From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drop_monitor: Add error code to detect duplicate state
 changes
Date: Tue, 20 Jul 2010 13:28:15 -0700 (PDT)
Message-ID: <20100720.132815.200094983.davem@davemloft.net>
References: <20100720145209.GE1995@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51303
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758627Ab0GTU17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 16:27:59 -0400
In-Reply-To: <20100720145209.GE1995@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 20 Jul 2010 10:52:09 -0400

> Hey-
> 	Patch to add -EAGAIN error to dropwatch netlink message handling code.
> -EAGAIN will be returned anytime userspace attempts to transition the state of
> the drop monitor service to a state that its already in.  That allows user space
> to detect this condition, so it doesn't wait for a success ACK that will never
> arrive.  Tested successfully by me
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
