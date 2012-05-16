From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] mISDN: avmfritz use the bigger fifo of chip
 version 2
Date: Wed, 16 May 2012 01:16:15 -0400 (EDT)
Message-ID: <20120516.011615.2055798345695085276.davem@davemloft.net>
References: <1337142174-8304-1-git-send-email-kkeil@linux-pingi.de>
	<1337142174-8304-4-git-send-email-kkeil@linux-pingi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kkeil@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45463 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965132Ab2EPFQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 01:16:19 -0400
In-Reply-To: <1337142174-8304-4-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@linux-pingi.de>
Date: Wed, 16 May 2012 06:22:49 +0200

> +	mode = (AVM_FRITZ_PCIV2 == fc->type) ? HDLC_FIFO_SIZE_128 : 0;

Please don't do this "CONSTANT == variable" type testing order, it's
completely unnatural and not something we commonly do elsewhere in the
networking code.

I know some coders bible somewhere says that this is how you avoid
accidental assignments, but it's too ugly to live.
