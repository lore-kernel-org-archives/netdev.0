From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6/l3mdev: Move host route on saved
 address if necessary
Date: Tue, 01 Mar 2016 17:23:12 -0500 (EST)
Message-ID: <20160301.172312.1539246311423803200.davem@davemloft.net>
References: <1456595957-29477-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42678 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbcCAWXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 17:23:14 -0500
In-Reply-To: <1456595957-29477-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sat, 27 Feb 2016 09:59:17 -0800

> Commit f1705ec197e70 allows IPv6 addresses to be retained on a link down.
> The address can have a cached host route which can point to the wrong
> FIB table if the L3 enslavement is changed (e.g., route can point to local
> table instead of VRF table if device is added to an L3 domain).
> 
> On link up check the table of the cached host route against the FIB
> table associated with the device and correct if needed.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Ugly... but applied, thanks.
