From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] b44: fix misalignment and wasted space in rx
 handling
Date: Fri, 09 Jan 2009 23:08:17 -0800 (PST)
Message-ID: <20090109.230817.36393679.davem@davemloft.net>
References: <4967459D.3070207@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mb@bu3sch.de
To: nbd@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56608
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752221AbZAJHIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:08:16 -0500
In-Reply-To: <4967459D.3070207@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Fietkau <nbd@openwrt.org>
Date: Fri, 09 Jan 2009 13:39:57 +0100

> Broadcom 4400 puts a header of configurable size (apparently needs
> to be at least 28 bytes) in front of received packets. When handling
> this, the previous code accidentally added the offset 30 *twice* for
> the software and once for the hardware, thereby cancelling out the
> IP alignment effect of the 30 byte padding and wasting an additional
> 30 bytes of memory per packet.
> 
> This patch fixes this problem and improves routing throughput by
> about 30% on MIPS, where unaligned access is expensive.
> 
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

Applied.
