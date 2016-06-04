From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qed: Fix next-ptr chains for BE / 32-bit
Date: Fri, 03 Jun 2016 22:42:40 -0700 (PDT)
Message-ID: <20160603.224240.1235800253136093689.davem@davemloft.net>
References: <1465017616-3892-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbcFDFml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 01:42:41 -0400
In-Reply-To: <1465017616-3892-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Sat, 4 Jun 2016 08:20:16 +0300

> Commit a91eb52abb50 ("qed: Revisit chain implementation") contains an
> incorrect implementation for BE platforms, as device's regpairs containing
> addresses are LE and they're not converted correctly when read back.
> In addition, it raises a compilation warning for 32-bit platforms where
> dma_addr_t is a 32-bit variable.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied, thanks.
