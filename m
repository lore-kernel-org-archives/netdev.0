From: David Miller <davem@davemloft.net>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next v3] 6lowpan: mac802154:
 fix coding style issues
Date: Tue, 01 Jul 2014 22:14:23 -0700 (PDT)
Message-ID: <20140701.221423.427836851370173361.davem@davemloft.net>
References: <1404276016.14624.57.camel@joe-AO725>
	<CAGVrzcb6pYdyvuXOrKssjx2fzJqRV=CsdocVNGSSKkEAuUkeYg@mail.gmail.com>
	<1404277090.14624.62.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, varkabhadram@gmail.com,
	netdev@vger.kernel.org, varkab@cdac.in,
	linux-zigbee-devel@lists.sourceforge.net
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585AbaGBFOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 01:14:25 -0400
In-Reply-To: <1404277090.14624.62.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 01 Jul 2014 21:58:10 -0700

> The code is currently:
> 
> 	__raw_writel(upper_32_bits(addr) & DESC_ADDR_HI_MASK,
> 			d + DESC_ADDR_HI_STATUS_LEN);
> 
> 1st line has 1 leading tab,
> 2nd line has 3 leading tabs
> 
> For networking code style, this should be:
> 
> 	__raw_writel(upper_32_bits(addr) & DESC_ADDR_HI_MASK,
> 		     d + DESC_ADDR_HI_STATUS_LEN);
> 
> 1st line has 1 leading tab,
> 2nd line has 2 leading tabs followed by 5 leading spaces
> 
> This aligns the 2nd line arguments to the position immediately
> after the open parenthesis.

+1
