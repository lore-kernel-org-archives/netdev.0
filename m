From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vrf: Fix crash when IPv6 is disabled at
 boot time
Date: Thu, 09 Jun 2016 23:34:58 -0700 (PDT)
Message-ID: <20160609.233458.1449029966409837912.davem@davemloft.net>
References: <1465492860-19246-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54069 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbcFJGe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 02:34:59 -0400
In-Reply-To: <1465492860-19246-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu,  9 Jun 2016 10:21:00 -0700

> Frank Kellermann reported a kernel crash with 4.5.0 when IPv6 is
> disabled at boot using the kernel option ipv6.disable=1. Using
> current net-next with the boot option:
> 
> $ ip link add red type vrf table 1001
 ...
> The problem above is due to the fact that the fib hash table is not
> allocated when IPv6 is disabled at boot.
> 
> As for the VRF driver it should not do any IPv6 initializations if IPv6
> is disabled, so it needs to know if IPv6 is disabled at boot. The disable
> parameter is private to the IPv6 module, so provide an accessor for
> modules to determine if IPv6 was disabled at boot time.
> 
> Fixes: 35402e3136634 ("net: Add IPv6 support to VRF device")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
