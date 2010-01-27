From: David Miller <davem@davemloft.net>
Subject: Re: Hang: 2.6.32.4 sky2/DMAR
Date: Wed, 27 Jan 2010 15:54:23 -0800 (PST)
Message-ID: <20100127.155423.169231741.davem@davemloft.net>
References: <20100127085049.5b5048e9@nehalam>
	<4B60707F.1000608@majjas.com>
	<20100127094531.53c85aa7@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mbreuer@majjas.com, jarkao2@gmail.com, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mchan@broadcom.com, pcnet32@verizon.net,
	romieu@fr.zoreil.com, mcarlson@broadcom.com
To: shemminger@vyatta.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754800Ab0A0XyS@vger.kernel.org>
In-Reply-To: <20100127094531.53c85aa7@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 27 Jan 2010 09:45:31 -0800

> Setting it to 1 causes driver to never go through the dma_sync_single/memcpy
> path.  Perhaps the code for DMAR doesn't do dma_sync_single_for_cpu
> properly, or the value passed to sync_single_for_cpu doesn't account for
> all the overhead of padding and/or ether header.

For the millionth time...

DMAR does not implement any of the DMA SYNC operations, they are set
to NULL in the dma ops vector, and thus are NOPs.
