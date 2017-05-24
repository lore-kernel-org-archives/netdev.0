From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/8] mlxsw: Support firmware flash
Date: Wed, 24 May 2017 16:33:28 -0400 (EDT)
Message-ID: <20170524.163328.672261790569871029.davem@davemloft.net>
References: <20170523195630.6460-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, yotamg@mellanox.com,
        mlxsw@mellanox.com, Yuval.Mintz@cavium.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50066 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbdEXUdb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 16:33:31 -0400
In-Reply-To: <20170523195630.6460-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 23 May 2017 21:56:22 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Add support for device firmware flash on mlxsw spectrum. The firmware files
> are expected to be in the Mellanox Firmware Archive version 2 (MFA2)
> format.
> 
> The firmware flash is triggered on driver initialization time if the device
> firmware version does not meet the minimum firmware version supported by
> the driver.
> 
> Currently, to activate the newly flashed firmware, the user needs to
> reboot his system.
> 
> The first patch introduces the mlxfw module, which implements common logic
> needed for the firmware flash process on Mellanox products, such as the
> MFA2 format parsing and the firmware flash state machine logic. As the
> module implements common logic which will be needed by various different
> Mellanox drivers, it defines a set of callbacks needed to interact with the
> specific device.
> 
> Patches 1-5 implement the needed mlxfw callbacks in the mlxsw spectrum
> driver.
> 
> Patches 6 and 7 add boot-time firmware upgrade on the mlxsw spectrum
> driver.
> 
> Patch 8 adds a fix needed for new firmware versions.

Series applied, although I hope you sort out the user interface
soon otherwise most of this is completely dead unused code.

Thanks.
