From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] r8169: fix invalid register dump
Date: Tue, 20 Aug 2013 15:02:13 -0700 (PDT)
Message-ID: <20130820.150213.1489180923839317674.davem@davemloft.net>
References: <1376833298-7321-1-git-send-email-lekensteyn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, nic_swsd@realtek.com
To: lekensteyn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145Ab3HTWCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 18:02:14 -0400
In-Reply-To: <1376833298-7321-1-git-send-email-lekensteyn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Wu <lekensteyn@gmail.com>
Date: Sun, 18 Aug 2013 15:41:38 +0200

> For some reason, my PCIe RTL8111E onboard NIC on a GA-Z68X-UD3H-B3
> motherboard reads as FFs when reading from MMIO with a block size
> larger than 7. Therefore change to reading blocks of four bytes.
> 
> Ben Hutchings noted that the buffer is large enough to hold all
> registers, so now all registers are read. Since regs->len is not used
> anymore, drop the superfluous range check as well. (ethtool would
> already ensure that regs->len <= R8169_REGS_SIZE).
> 
> Signed-off-by: Peter Wu <lekensteyn@gmail.com>
> ---
> Hi,
> 
> This partly obsoletes "r8169,sis190: remove unnecessary length
> check"[1]. I do not have sis190 hardware, but since that is based on
> this r8169 driver, would it make sense to apply this patch to sis190
> too?

You're going to have to respin this since I applied the length
check removal patch already.

Thanks.
