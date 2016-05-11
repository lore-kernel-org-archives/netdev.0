From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 net-next 0/7] More enabler patches for DSA probing
Date: Wed, 11 May 2016 19:36:58 -0400 (EDT)
Message-ID: <20160511.193658.976667252714550868.davem@davemloft.net>
References: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
	netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53032 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbcEKXhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 19:37:01 -0400
In-Reply-To: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 10 May 2016 23:27:18 +0200

> The complete set of patches for the reworked DSA probing is too big to
> post as once. These subset contains some enablers which are easy to
> review.
> 
> Eventually, the Marvell driver will instantiate its own internal MDIO
> bus, rather than have the framework do it, thus allows devices on the
> bus to be listed in the device tree. Initialize the main mutex as soon
> as it is created, to avoid lifetime issues with the mdio bus.
> 
> A previous patch renamed all the DSA probe functions to make room for
> a true device probe. However the recent merging of all the Marvell
> switch drivers resulted in mv88e6xxx going back to the old probe
> name. Rename it again, so we can have a driver probe function.
> 
> Add minimum support for the Marvell switch driver to probe as an MDIO
> device, as well as an DSA driver. Later patches will then register
> this device with the new DSA core framework.
> 
> Move the GPIO reset code out of the DSA code. Different drivers may
> need different reset mechanisms, e.g. via a reset controller for
> memory mapped devices. Don't clutter up the core with this. Let each
> driver implement what it needs.
> 
> master_dev is no longer needed in the switch drivers, since they have
> access to a device pointer from the probe function. Remove it.
> 
> Let the switch parse the eeprom length from its one device tree
> node. This is required with the new binding when the central DSA
> platform device no longer exists.

Series applied, thanks Andrew.
