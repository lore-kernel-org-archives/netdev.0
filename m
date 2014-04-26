From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] Altera Triple Speed Ethernet (TSE) Driver
Date: Sat, 26 Apr 2014 12:27:55 -0400 (EDT)
Message-ID: <20140426.122755.879078420691802138.davem@davemloft.net>
References: <1398376691-15265-1-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vbridgers2013@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52409 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581AbaDZQ14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 12:27:56 -0400
In-Reply-To: <1398376691-15265-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridgers2013@gmail.com>
Date: Thu, 24 Apr 2014 16:58:07 -0500

> This series of patches addresses a handful of issues found in testing
> and reported by users of the Altera Triple Speed Ethernet soft IP.
> 
> The patches address the following issues (in summary)
> 
> 1) The SGDMA soft IP was found to incorrectly process receive packets
>    when the target physical address of the receive buffer was on
>    a boundary that's not 32-bit aligned. One of the patches addresses
>    this issue.
> 2) The pause quanta was not being set by the driver, one patch of this
>    series sets the pause quanta to the IEEE defined default value
>    since the hardware reset value is 0.
> 3) An issue in a error recovery path of the probe routine caused a 
>    kernel panic in the event a phy was probed and could not be found.
>    A patch addresses this issue. 
> 4) A change was made to the driver name for Ethtool support, and 
>    comments added to support an addition to Ethtool to support
>    the Altera Triple Speed Ethernet controller.

Since these are bug fixes I've applied them to 'net' instead of 'net-next'.

Please always submit your changes against the correct tree, thank you.
