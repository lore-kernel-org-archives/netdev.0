From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vrf: correct FRA_L3MDEV encode type
Date: Wed, 01 Nov 2017 11:42:40 +0900 (KST)
Message-ID: <20171101.114240.823282349339020372.davem@davemloft.net>
References: <20171101012414.1637-1-0xeffeff@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: 0xeffeff@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44158 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKACmm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:42:42 -0400
In-Reply-To: <20171101012414.1637-1-0xeffeff@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Barnhill <0xeffeff@gmail.com>
Date: Wed,  1 Nov 2017 01:24:14 +0000

> FRA_L3MDEV is defined as U8, but is being added as a U32 attribute. On
> big endian architecture, this results in the l3mdev entry not being
> added to the FIB rules.
> 
> Fixes: 1aa6c4f6b8cd8 ("net: vrf: Add l3mdev rules on first device create")

Please resubmit this with a proper "Signed-off-by: " tag, thank you.
