From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sungem: Fix WakeOnLan
Date: Thu, 03 May 2012 01:43:30 -0400 (EDT)
Message-ID: <20120503.014330.1072601379213618284.davem@davemloft.net>
References: <1335639157-6336-1-git-send-email-gerard.lledo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerard.lledo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286Ab2ECFnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 01:43:32 -0400
In-Reply-To: <1335639157-6336-1-git-send-email-gerard.lledo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Lledo <gerard.lledo@gmail.com>
Date: Sat, 28 Apr 2012 21:52:37 +0300

> From: Gerard Lledo <gerard.lledo@gmail.com>
> 
> WakeOnLan was broken in this driver because gp->asleep_wol is a 1-bit
> bitfield and it was being assigned WAKE_MAGIC, which is (1 << 5).
> gp->asleep_wol remains 0 and the machine never wakes up.  Fixed by casting
> gp->wake_on_lan to bool.  Tested on an iBook G4.
> 
> Signed-off-by: Gerard Lledo <gerard.lledo@gmail.com>

Applied and queued up for -stable, thanks.
