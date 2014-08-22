From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Revert UNDI flushing mechanism
Date: Thu, 21 Aug 2014 17:55:32 -0700 (PDT)
Message-ID: <20140821.175532.2001740724595557372.davem@davemloft.net>
References: <1408390583-22693-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44727 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755487AbaHVAzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 20:55:33 -0400
In-Reply-To: <1408390583-22693-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 18 Aug 2014 22:36:23 +0300

> Commit 91ebb929b6f8 ("bnx2x: Add support for Multi-Function UNDI") [which was
> later supposedly fixed by de682941eef3 ("bnx2x: Fix UNDI driver unload")]
> introduced a bug in which in some [yet-to-be-determined] scenarios the
> alternative flushing mechanism which was to guarantee the Rx buffers are
> empty before resetting them during device probe will fail.
> If this happens, when device will be loaded once more a fatal attention will
> occur; Since this most likely happens in boot from SAN scenarios, the machine
> will fail to load.
> 
> Notice this may occur not only in the 'Multi-Function' scenario but in the
> regular scenario as well, i.e., this introduced a regression in the driver's
> ability to perform boot from SAN.
> 
> The patch reverts the mechanism and applies the old scheme to multi-function
> devices as well as to single-function devices.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Applied and queued up for -stable, thanks.
