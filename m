From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: pch_gbe: Fix TX RX descriptor accesses for big
 endian systems
Date: Thu, 02 Mar 2017 13:05:27 -0800 (PST)
Message-ID: <20170302.130527.1814024336719792592.davem@davemloft.net>
References: <1488334402-13557-1-git-send-email-hassan.naveed@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, paul.burton@imgtec.com,
        matt.redfearn@imgtec.com, fw@strlen.de, romieu@fr.zoreil.com
To: hassan.naveed@imgtec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39446 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751009AbdCBXAu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 18:00:50 -0500
In-Reply-To: <1488334402-13557-1-git-send-email-hassan.naveed@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hassan Naveed <hassan.naveed@imgtec.com>
Date: Tue, 28 Feb 2017 18:13:22 -0800

> Fix pch_gbe driver for ethernet operations for a big endian CPU.
> Values written to and read from transmit and receive descriptors
> in the pch_gbe driver are byte swapped from the perspective of a
> big endian CPU, since the ethernet controller always operates in
> little endian mode. Rectify this by appropriately byte swapping
> these descriptor field values in the driver software.
> 
> Signed-off-by: Hassan Naveed <hassan.naveed@imgtec.com>
> Reviewed-by: Paul Burton <paul.burton@imgtec.com>
> Reviewed-by: Matt Redfearn <matt.redfearn@imgtec.com>
> Cc: Paul Burton <paul.burton@imgtec.com>
> Cc: Matt Redfearn <matt.redfearn@imgtec.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Florian Westphal <fw@strlen.de>
> Cc: françois romieu <romieu@fr.zoreil.com>
> ---
> Changes in v2: Additionally changed transmit and receive descriptors field
> types to __le{16,32}. Ran sparse with endianness checking enabled and no
> new warnings were generated.

This doesn't apply cleanly to the 'net' tree, please respin.
