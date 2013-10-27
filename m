From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] be2net: Warn users of possible broken
 functionality on BE2 cards with very old FW versions with latest driver
Date: Sun, 27 Oct 2013 16:38:39 -0400 (EDT)
Message-ID: <20131027.163839.96252964093040835.davem@davemloft.net>
References: <62f97dab-6b78-43bd-9b77-36c7f0dcdbf8@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229Ab3J0Uik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 16:38:40 -0400
In-Reply-To: <62f97dab-6b78-43bd-9b77-36c7f0dcdbf8@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Thu, 24 Oct 2013 14:37:53 +0530

> On very old FW versions < 4.0, the mailbox command to set interrupts
> on the card succeeds even though it is not supported and should have
> failed, leading to a scenario where interrupts do not work.
> Hence warn users to upgrade to a suitable FW version to avoid seeing
> broken functionality.
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied, thanks.
