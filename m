From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/19] sky2: remove unnecessary reads of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 21:42:12 -0700 (PDT)
Message-ID: <20110627.214212.364989192938099400.davem@davemloft.net>
References: <1309196816-16198-1-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57264 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756534Ab1F1EmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 00:42:17 -0400
In-Reply-To: <1309196816-16198-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jdmason@kudzu.us>
Date: Mon, 27 Jun 2011 12:46:56 -0500

> The PCIE capability offset is saved during PCI bus walking.  It will
> remove an unnecessary search in the PCI configuration space if this
> value is referenced instead of reacquiring it.  Also, pci_is_pcie is a
> better way of determining if the device is PCIE or not (as it uses the
> same saved PCIE capability offset).
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>

Applied.
