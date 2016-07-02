From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: dp83867: Fix initialization of PHYCR register
Date: Sat, 02 Jul 2016 14:49:24 -0400 (EDT)
Message-ID: <20160702.144924.2057687330898460203.davem@davemloft.net>
References: <1467405303-19212-1-git-send-email-stefan@shauser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: stefan@shauser.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [184.105.139.130] ([184.105.139.130]:37722 "EHLO
	shards.monkeyblade.net" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750800AbcGBStc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 14:49:32 -0400
In-Reply-To: <1467405303-19212-1-git-send-email-stefan@shauser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hauser <stefan@shauser.net>
Date: Fri,  1 Jul 2016 22:35:03 +0200

> When initializing the PHY control register, the FIFO depth bits are
> written without reading the previous register value, i.e. all other
> bits are overwritten with zero. This disables automatic MDI-X
> configuration, which is enabled by default. Fix initialization by doing
> a read/modify/write operation.
> 
> Signed-off-by: Stefan Hauser <stefan@shauser.net>

Applied.
