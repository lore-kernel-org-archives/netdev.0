From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bna: Replace large udelay() with mdelay()
Date: Mon, 10 Mar 2014 15:57:23 -0400 (EDT)
Message-ID: <20140310.155723.1592181647227868708.davem@davemloft.net>
References: <1394337802.2861.71.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vagrant@debian.org, rmody@brocade.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900AbaCJT5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 15:57:25 -0400
In-Reply-To: <1394337802.2861.71.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 09 Mar 2014 04:03:22 +0000

> udelay() does not work on some architectures for values above
> 2000, in particular on ARM:
> 
> ERROR: "__bad_udelay" [drivers/net/ethernet/brocade/bna/bna.ko] undefined!
> 
> Reported-by: Vagrant Cascadian <vagrant@debian.org>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied, thanks Ben.

Do you want me to queue this up for -stable?
