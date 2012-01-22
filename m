From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] skge: check for PCI dma mapping errors
Date: Sun, 22 Jan 2012 14:24:30 -0500 (EST)
Message-ID: <20120122.142430.2246664886401102664.davem@davemloft.net>
References: <20120119163718.35bedfcc@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384Ab2AVTYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 14:24:33 -0500
In-Reply-To: <20120119163718.35bedfcc@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 19 Jan 2012 16:37:18 -0800

> Driver should check for mapping errors.
> Machines with limited DMA maps may return an error when a PCI map is
> requested (not an issue on standard x86). 
> 
> Also use upper/lower 32 bits macros for clarity.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
