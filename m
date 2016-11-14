From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] cadence: Add LSO support.
Date: Mon, 14 Nov 2016 12:30:38 -0500 (EST)
Message-ID: <20161114.123038.1075174354580074536.davem@davemloft.net>
References: <BN3PR07MB2516C30913D2FB8D4788071AC9BC0@BN3PR07MB2516.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: rafalo@cadence.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37532 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752814AbcKNRak (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 12:30:40 -0500
In-Reply-To: <BN3PR07MB2516C30913D2FB8D4788071AC9BC0@BN3PR07MB2516.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafal Ozieblo <rafalo@cadence.com>
Date: Mon, 14 Nov 2016 09:32:34 +0000

>> If UFO is in use it should not silently disable UDP checksums.
>> 
>> If you cannot support UFO with proper checksumming, then you cannot enable support for that feature.
> 
> According Cadence Gigabit Ethernet MAC documentation:
> 
> "Hardware will not calculate the UDP checksum or modify the UDP checksum field. Therefore software
> must set a value of zero in the checksum field in the UDP header (in the first payload buffer)
> to indicate to the receiver that the UDP datagram does not include a checksum."
> 
> It is hardware requirement.

I do not doubt that it is a hardware restriction.

But I am saying that you cannot enable this feature under Linux if
this is how it operates on your hardware.
