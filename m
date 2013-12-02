From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: emaclite: add barriers to support Xilinx Zynq
 platform
Date: Sun, 01 Dec 2013 20:09:06 -0500 (EST)
Message-ID: <20131201.200906.25118738399177322.davem@davemloft.net>
References: <1385623797-26034-1-git-send-email-sthokal@xilinx.com>
	<9045da6f-88e5-4a20-be68-477790588131@TX2EHSMHS023.ehs.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	michal.simek@xilinx.com, sthokal@xilinx.com
To: srikanth.thokala@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967Ab3LBBJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 20:09:10 -0500
In-Reply-To: <9045da6f-88e5-4a20-be68-477790588131@TX2EHSMHS023.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srikanth Thokala <srikanth.thokala@xilinx.com>
Date: Thu, 28 Nov 2013 12:59:57 +0530

> This patch adds barriers at appropriate places to ensure the driver
> works on Xilinx Zynq ARM-based SoC platform.
> 
> Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>

Memory barriers must have comments.

Specifically, the comment must describe what exactly is being ensured
by the memory barrier.  What entity must see what memory operations in
what order?
