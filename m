From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/19] cxgb3: remove unnecessary read of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 21:41:02 -0700 (PDT)
Message-ID: <20110627.214102.1698622522216931326.davem@davemloft.net>
References: <1309196569-15926-1-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57233 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754272Ab1F1ElM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 00:41:12 -0400
In-Reply-To: <1309196569-15926-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jdmason@kudzu.us>
Date: Mon, 27 Jun 2011 12:42:49 -0500

> The PCIE capability offset is saved during PCI bus walking.  It will
> remove an unnecessary search in the PCI configuration space if this
> value is referenced instead of reacquiring it.
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>

Applied.
