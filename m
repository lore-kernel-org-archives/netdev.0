From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Fri, 10 Jun 2016 22:51:56 -0700 (PDT)
Message-ID: <20160610.225156.638004322598763463.davem@davemloft.net>
References: <1465323757-7249-1-git-send-email-mario_limonciello@dell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	pali.rohar@gmail.com, anthony.wong@canonical.com,
	gregkh@linuxfoundation.org
To: mario_limonciello@dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034AbcFKFv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 01:51:58 -0400
In-Reply-To: <1465323757-7249-1-git-send-email-mario_limonciello@dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mario Limonciello <mario_limonciello@dell.com>
Date: Tue,  7 Jun 2016 13:22:37 -0500

> The RTL8153-AD supports a persistent system specific MAC address.
> This means a device plugged into two different systems with host side
> support will show different (but persistent) MAC addresses.
> 
> This information for the system's persistent MAC address is burned in when
> the system HW is built and available under \_SB.AMAC in the DSDT at runtime.
> 
> This technology is currently implemented in the Dell TB15 and WD15 Type-C
> docks.  More information is available here:
> http://www.dell.com/support/article/us/en/04/SLN301147
> 
> Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
> ---
> Changes from v5:
>  * Correct return value if hex2bin succesful but invalid ether addr

Have things calmed down enough now that I can apply this?

Let's see some ACKs.
