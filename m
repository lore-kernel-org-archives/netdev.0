From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: fix a wrapping bug in isdn_ppp_ioctl()
Date: Wed, 10 Oct 2012 22:46:14 -0400 (EDT)
Message-ID: <20121010.224614.1474455483126634181.davem@davemloft.net>
References: <20121010093816.GA3669@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, standby24x7@gmail.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933061Ab2JKCqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 22:46:16 -0400
In-Reply-To: <20121010093816.GA3669@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 10 Oct 2012 12:42:18 +0300

> "protos" is an array of unsigned longs and "i" is the number of bits in
> an unsigned long so we need to use 1UL as well to prevent the shift
> from wrapping around.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

I'll apply this, thanks.
