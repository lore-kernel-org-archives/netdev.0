From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/19] r8169: remove unnecessary read of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 21:41:40 -0700 (PDT)
Message-ID: <20110627.214140.344048444882489906.davem@davemloft.net>
References: <1309196791-16157-1-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756172Ab1F1Elu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 00:41:50 -0400
In-Reply-To: <1309196791-16157-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jdmason@kudzu.us>
Date: Mon, 27 Jun 2011 12:46:31 -0500

> The PCIE capability offset is saved during PCI bus walking.  Use the
> value from pci_dev instead of checking in the driver and saving it off
> the the driver specific structure.  Also, it will remove an unnecessary
> search in the PCI configuration space if this value is referenced
> instead of reacquiring it.
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>

Applied.
