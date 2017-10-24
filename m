From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: cavium: octeon: Switch to using
 netdev_info().
Date: Tue, 24 Oct 2017 18:38:56 +0900 (KST)
Message-ID: <20171024.183856.2137780150878550105.davem@davemloft.net>
References: <1508777005-20938-1-git-send-email-steven.hill@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.daney@cavium.com
To: steven.hill@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58254 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751862AbdJXJjA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:39:00 -0400
In-Reply-To: <1508777005-20938-1-git-send-email-steven.hill@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Steven J. Hill" <steven.hill@cavium.com>
Date: Mon, 23 Oct 2017 11:43:25 -0500

> @@ -705,14 +705,15 @@ static int octeon_mgmt_ioctl_hwtstamp(struct net_device *netdev,
>  			u64 clock_comp = (NSEC_PER_SEC << 32) /	octeon_get_io_clock_rate();
>  			if (!ptp.s.ptp_en)
>  				cvmx_write_csr(CVMX_MIO_PTP_CLOCK_COMP, clock_comp);
> -			pr_info("PTP Clock: Using sclk reference at %lld Hz\n",
> +			netdev_info(netdev,
> +				"PTP Clock: Using sclk reference at %lld Hz\n",

Please get the argument alignment correct when you make changes like this.

For a function call, the arguments on the second and subsequent line of
arguments must start exactly at the first column after the openning
parenthesis of the call.

You must use the appropriate number of TAB then SPACE characters necessary
to achieve this.

Thank you.
