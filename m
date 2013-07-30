From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 04/15] ixgbe: add new media type
Date: Mon, 29 Jul 2013 22:20:07 -0700 (PDT)
Message-ID: <20130729.222007.1519767834860729149.davem@davemloft.net>
References: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1375102331-23905-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: donald.c.skidmore@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57282 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755651Ab3G3FUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 01:20:08 -0400
In-Reply-To: <1375102331-23905-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 29 Jul 2013 05:52:00 -0700

> +	status = hw->phy.ops.write_i2c_byte(hw, IXGBE_SFF_SFF_8472_OSCB,
> +					    IXGBE_I2C_EEPROM_DEV_ADDR2,
> +					    eeprom_data);
> +	if (status) {
> +		hw_dbg(hw, "Failed to read Rx Rate Select RS1\n");
> +		goto out;
> +	}

Either the call, or the debugging message, is wrong.

They don't agree on whether this is a read or a write.
