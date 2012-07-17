From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbevf: Prevent RX/TX statistics getting reset to zero
Date: Mon, 16 Jul 2012 22:45:00 -0700 (PDT)
Message-ID: <20120716.224500.294857675537016703.davem@davemloft.net>
References: <1342488281-8358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: narendra_k@dell.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46238 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754577Ab2GQFpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:45:01 -0400
In-Reply-To: <1342488281-8358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 16 Jul 2012 18:24:41 -0700

> From: Narendra K <narendra_k@dell.com>
> 
> The commit 4197aa7bb81877ebb06e4f2cc1b5fea2da23a7bd implements 64 bit
> per ring statistics. But the driver resets the 'total_bytes' and
> 'total_packets' from RX and TX rings in the RX and TX interrupt
> handlers to zero. This results in statistics being lost and user space
> reporting RX and TX statistics as zero. This patch addresses the
> issue by preventing the resetting of RX and TX ring statistics to
> zero.
> 
> Signed-off-by: Narendra K <narendra_k@dell.com>
> Tested-by: Sibai Li <sibai.li@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
