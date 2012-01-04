From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/8] RX NFC support for hash-based filters
Date: Wed, 04 Jan 2012 14:11:11 -0500 (EST)
Message-ID: <20120104.141111.16071561018650942.davem@davemloft.net>
References: <1325627819.2832.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754977Ab2ADTLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 14:11:16 -0500
In-Reply-To: <1325627819.2832.31.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 3 Jan 2012 21:56:59 +0000

> 1. Fix gianfar's validation of filter rule locations.  In the previous
>    version of this series, this was a requirement for part 2, but that's
>    no longer the case.
> 
> 2. Extend ethtool RX NFC rules API to support hash-based filter hardware
>    in which rule locations should be selected by the driver or firmware.
> 
> 3. Change the sfc driver to implement this API instead of RX n-tuple.
> 
> 4. Remove support for RX n-tuple, now that there are no in-tree
>    implementations.

All applied, I had to fix some trailing whitespace errors in patches
5 and 6.
