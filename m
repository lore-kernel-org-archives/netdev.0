From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/6] cnic: Fix ring setup/shutdown code
Date: Thu, 14 Jul 2011 08:46:33 -0700 (PDT)
Message-ID: <20110714.084633.1868435195489895600.davem@davemloft.net>
References: <1310613862-27497-1-git-send-email-mchan@broadcom.com>
	<1310613862-27497-2-git-send-email-mchan@broadcom.com>
	<1310613862-27497-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754795Ab1GNPqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 11:46:36 -0400
In-Reply-To: <1310613862-27497-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 13 Jul 2011 20:24:19 -0700

> Latest bnx2x driver uses different CID for the iSCSI rings, so
> we need to pass it in the ring init data.  The rx ring is also
> zeroed out to prevent stale DMA addresses from being used after
> shutdown.
> 
> The same cp local variable redefined inside the else branch is
> also eliminated.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

Applied.
