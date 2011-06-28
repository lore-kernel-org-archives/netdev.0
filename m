From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/19] bnx2x: remove unnecessary read of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 21:41:27 -0700 (PDT)
Message-ID: <20110627.214127.1396275314907942562.davem@davemloft.net>
References: <1309196712-16081-1-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755989Ab1F1Ela (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 00:41:30 -0400
In-Reply-To: <1309196712-16081-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jdmason@kudzu.us>
Date: Mon, 27 Jun 2011 12:45:12 -0500

> The PCIE capability offset is saved during PCI bus walking.  It will
> remove an unnecessary search in the PCI configuration space if this
> value is referenced instead of reacquiring it.  Also, pci_is_pcie is a
> better way of determining if the device is PCIE or not (as it uses the
> same saved PCIE capability offset).
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>

Applied.
