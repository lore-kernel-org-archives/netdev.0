From: David Miller <davem@davemloft.net>
Subject: Re: [next PATCH 0/4] Add support for generic Tx checksums to igb,
 ixgbe, igbvf, ixgbevf
Date: Mon, 11 Jan 2016 23:43:54 -0500 (EST)
Message-ID: <20160111.234354.379572319999796564.davem@davemloft.net>
References: <20160111173724.4101.35798.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	tom@herbertland.com, netdev@vger.kernel.org
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761739AbcALEn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 23:43:57 -0500
In-Reply-To: <20160111173724.4101.35798.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Mon, 11 Jan 2016 09:53:50 -0800

> It turns out we were doing far more than we needed to in the Tx checksum
> functions for the drivers.  As a result it hid the fact that the hardware
> is actually much more capable of handling generic offloads then previously
> realized.
> 
> This patch series enables generic Tx checksum support for igb and ixgbe
> based Intel server adapters.  In addition it adds a number of other items
> such as:
>   Inner checksum support for MPLS
>   Encapsulated checksum support for igb, igbvf, and ixgbevf
>   SCTP CRC offload support for VLAN tunnels, and VFs
>   IPv6 extension header support for igb and igbvf

I like this series, nice work!

This can go in when net-next opens back up, and I assume I'll get
it via Jeff K.
