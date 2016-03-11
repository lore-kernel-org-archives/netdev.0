From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [v2, resend] b43: Fix memory leaks in b43_bus_dev_ssb_init and
 b43_bus_dev_bcma_init
Date: Fri, 11 Mar 2016 21:52:30 +0530
Message-ID: <20160311162230.GA5436@sudip-laptop>
References: <1452949690-16387-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo@codeaurora.org, zajec5@gmail.com, joe@perches.com,
	davem@davemloft.net, m@bues.ch, johannes.berg@intel.com,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33893 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932473AbcCKQWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 11:22:44 -0500
Content-Disposition: inline
In-Reply-To: <1452949690-16387-1-git-send-email-baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 16, 2016 at 09:08:10PM +0800, Jia-Ju Bai wrote:
> The memory allocated by kzalloc in b43_bus_dev_ssb_init and
> b43_bus_dev_bcma_init is not freed.
> This patch fixes the bug by adding kfree in b43_ssb_remove,
> b43_bcma_remove and error handling code of b43_bcma_probe.
> 
> Thanks Michael for his suggestion.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

The patch did not apply cleanly. I had to edit the patch to point to
drivers/net/wireless/broadcom/b43/main.c

For CONFIG_B43_SSB part-
Tested-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>

regards
sudip
