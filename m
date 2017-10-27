From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: deprecate 1-bit flag indicating
 watchdog kernel thread is running
Date: Fri, 27 Oct 2017 22:13:59 +0900 (KST)
Message-ID: <20171027.221359.1038015807348079952.davem@davemloft.net>
References: <20171026010456.GA17500@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49486 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752300AbdJ0NOF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 09:14:05 -0400
In-Reply-To: <20171026010456.GA17500@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 25 Oct 2017 18:04:56 -0700

> Deprecate the 1-bit flag (bit 2 in the SLI_SCRATCH_1 Octeon register) that
> indicates that the liquidio watchdog kernel thread is running for this NIC.
> Reason is:  it is incompatible with the firmware's use for SLI_SCRATCH_1.
> 
> In lieu of checking that now-deprecated flag, check the value of
> oct_dev->adapter_refcount to determine whether or not to create the
> watchdog kernel thread.
> 
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>

Applied.
