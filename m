From: David Miller <davem@davemloft.net>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on
 i211 using a device tree blob V4
Date: Wed, 17 Feb 2016 21:29:10 -0500 (EST)
Message-ID: <20160217.212910.1758016077144502307.davem@davemloft.net>
References: <56C506FD.5040408@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: jotihojr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424809AbcBRC3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 21:29:12 -0500
In-Reply-To: <56C506FD.5040408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Holland <jotihojr@gmail.com>
Date: Thu, 18 Feb 2016 00:49:17 +0100

> The Intel i211 LOM pcie ethernet controllers' iNVM operates as an OTP
> and has no externel EEPROM interface [1]. The following allows the
> driver to pickup the MAC address from a device tree blob when
> CONFIG_OF
> has been enabled.

Please use the generic eth_platform_get_mac_address(), or
alternatively structure your code like the ixgbe and other cases so
that SPARC and other OF platforms get this support as well.
