From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] r8169: fix invalid register dump
Date: Thu, 22 Aug 2013 14:26:34 -0700 (PDT)
Message-ID: <20130822.142634.140557723740177449.davem@davemloft.net>
References: <20130821205325.GA24054@electric-eye.fr.zoreil.com>
	<1377119831-29691-1-git-send-email-lekensteyn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	bhutchings@solarflare.com, romieu@fr.zoreil.com
To: lekensteyn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366Ab3HVV0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 17:26:37 -0400
In-Reply-To: <1377119831-29691-1-git-send-email-lekensteyn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Wu <lekensteyn@gmail.com>
Date: Wed, 21 Aug 2013 23:17:11 +0200

> For some reason, my PCIe RTL8111E onboard NIC on a GA-Z68X-UD3H-B3
> motherboard reads as FFs when reading from MMIO with a block size
> larger than 7. Therefore change to reading blocks of four bytes.
> 
> Ben Hutchings noted that the buffer is large enough to hold all
> registers, so now all registers are read.
> 
> Signed-off-by: Peter Wu <lekensteyn@gmail.com>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied, thanks.
