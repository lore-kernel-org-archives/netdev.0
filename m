From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] ethtool: Clarify use of size field for
 ETHTOOL_GRXFHINDIR
Date: Fri, 16 Dec 2011 13:53:30 -0500 (EST)
Message-ID: <20111216.135330.1343360459495231408.davem@davemloft.net>
References: <1323993076.2773.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	mcarlson@broadcom.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072Ab1LPSxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:53:35 -0500
In-Reply-To: <1323993076.2773.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 15 Dec 2011 23:51:16 +0000

> In order to find out the device's RX flow hash table size, ethtool
> initially uses ETHTOOL_GRXFHINDIR with a buffer size of zero.  This
> must be supported, but it is not necessary to support any other user
> buffer size less than the device table size.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
