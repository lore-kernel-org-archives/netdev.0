From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rose_dev: fix memcpy-bug in rose_set_mac_address
Date: Sun, 01 Apr 2012 16:16:46 -0400 (EDT)
Message-ID: <20120401.161646.248171300084857056.davem@davemloft.net>
References: <4F72D02F.6090907@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org
To: danborkmann@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414Ab2DAURP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 16:17:15 -0400
In-Reply-To: <4F72D02F.6090907@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <danborkmann@iogearbox.net>
Date: Wed, 28 Mar 2012 10:47:43 +0200

> If both addresses equal, nothing needs to be done. If the device is down,
> then we simply copy the new address to dev->dev_addr. If the device is up,
> then we add another loopback device with the new address, and if that does
> not fail, we remove the loopback device with the old address. And only
> then, we update the dev->dev_addr.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>

Applied and queued up for -stable.
