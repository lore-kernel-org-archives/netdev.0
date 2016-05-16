From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vrf: protect changes to private data
 with rcu
Date: Mon, 16 May 2016 13:47:46 -0400 (EDT)
Message-ID: <20160516.134746.1801114108978272123.davem@davemloft.net>
References: <1463167425-20416-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754419AbcEPRrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:47:47 -0400
In-Reply-To: <1463167425-20416-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri, 13 May 2016 12:23:45 -0700

> One cpu can be processing packets which includes using the cached route
> entries in the vrf device's private data and on another cpu the device
> gets deleted which releases the routes and sets the pointers in net_vrf
> to NULL. This results in datapath dereferencing a NULL pointer.
> 
> Fix by protecting access to dst's with rcu.
> 
> Fixes: 193125dbd8eb ("net: Introduce VRF device driver")
> Fixes: 35402e313663 ("net: Add IPv6 support to VRF device")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.

> Dave: I can handle the backports to stable branches if you prefer.

Sure, I'd really appreciate that.
