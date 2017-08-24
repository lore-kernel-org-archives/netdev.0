From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: change manner of detecting whether
 or not NIC firmware is loaded
Date: Wed, 23 Aug 2017 20:29:45 -0700 (PDT)
Message-ID: <20170823.202945.1564592947856218029.davem@davemloft.net>
References: <20170822194637.GA6875@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58080 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751102AbdHXD3q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 23:29:46 -0400
In-Reply-To: <20170822194637.GA6875@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Tue, 22 Aug 2017 12:46:37 -0700

> In the NIC firmware, the 1-bit flag indicating "firmware is loaded" moved
> from SLI_SCRATCH_1 to SLI_SCRATCH_2 (these are Octeon general-purpose
> scratch registers).  Make the PF driver conform to this change.
> 
> Remove code that sets the "firmware is loaded" flag because it's now the
> firmware's job to do that.
> 
> In the code that detects whether or not the firmware is loaded, don't just
> rely on checking the "firmware is loaded" flag because that may cause a
> rare false negative.  Add code that deduces whether or not the firmware is
> loaded; that will never give a false negative.
> 
> Also bump up driver version to match newer NIC firmware.
> 
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>

Applied.
