From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] if: restore token ring ARP type to header
Date: Tue, 22 May 2012 17:14:13 -0400 (EDT)
Message-ID: <20120522.171413.700107350345456852.davem@davemloft.net>
References: <20120522140105.284c28cd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494Ab2EVVOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 17:14:15 -0400
In-Reply-To: <20120522140105.284c28cd@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 22 May 2012 14:01:05 -0700

> Recent removal of Token Ring breaks the build of iproute2.
> 
> Even though Token Ring support is gone from the kernel, it is worth
> keeping the the definition of the TR ARP type to avoid breaking
> userspace programs that use this file.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Agreed, and applied, thanks Stephen.
