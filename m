From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: stmmac: socfgpa: Ensure emac bit set in
 System Manger for PTP
Date: Sun, 10 Apr 2016 23:44:48 -0400 (EDT)
Message-ID: <20160410.234448.508522535995412064.davem@davemloft.net>
References: <1460015735-8946-1-git-send-email-preid@electromag.com.au>
	<1460015735-8946-2-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: preid@electromag.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbcDKDou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 23:44:50 -0400
In-Reply-To: <1460015735-8946-2-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Reid <preid@electromag.com.au>
Date: Thu,  7 Apr 2016 15:55:35 +0800

> When using the PTP fpga to hps clock source for the stmmac module
> the appropriate bit in the System Manager FPGA Interface Group register
> needs to be set. This is not set by the bootloader setup  when the
> HPS emac pins are being for this emac module.
> 
> This allows the PTP clock to be sourced from the FPGA and also connects
> the PTP pps and ext trig signals to the stmmac PTP hardware.
> 
> Patch proposed by Phil Collins.
> 
> Signed-off-by: Phil Reid <preid@electromag.com.au>

Applied, thanks.
