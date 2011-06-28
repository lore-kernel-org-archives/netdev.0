From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/19] vxge: remove unnecessary reads of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 21:41:48 -0700 (PDT)
Message-ID: <20110627.214148.1900554404177455189.davem@davemloft.net>
References: <1309196891-16274-1-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756524Ab1F1Elv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 00:41:51 -0400
In-Reply-To: <1309196891-16274-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jdmason@kudzu.us>
Date: Mon, 27 Jun 2011 12:48:11 -0500

> The PCIE capability offset is saved during PCI bus walking.  It will
> remove an unnecessary search in the PCI configuration space if this
> value is referenced instead of reacquiring it.
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>

Applied.
