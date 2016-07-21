From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net/faraday: Disallow using reversed MAC
 address from hardware
Date: Wed, 20 Jul 2016 21:05:39 -0700 (PDT)
Message-ID: <20160720.210539.1359336662914040693.davem@davemloft.net>
References: <1469065374-9916-1-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org,
	David.Laight@ACULAB.COM
To: gwshan@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbcGUEFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 00:05:42 -0400
In-Reply-To: <1469065374-9916-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Date: Thu, 21 Jul 2016 11:42:54 +1000

> The initial MAC address is retrieved from hardware if it's not
> provided by device-tree. The reserved MAC address from hardware
> will be used if non-reserved MAC address is invalid. It will
> cause mismatched MAC address seen by hardware and software.
> 
> This disallows using the reserved hardware MAC address to avoid
> the mismatched MAC address seen by hardware and software.
> 
> Fixes: 113ce107afe9 ("net/faraday: Read MAC address from chip")
> Suggested-by: David Laight <David.Laight@ACULAB.COM>
> Suggested-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
> ---
> v2: Add "net-next" in the subject

Makes sense, applied, thanks.
