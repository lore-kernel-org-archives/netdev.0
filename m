From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/9] myri10ge: remove unnecessary read of PCI_CAP_ID_EXP
Date: Wed, 29 Jun 2011 06:03:30 -0700 (PDT)
Message-ID: <20110629.060330.497454533228165173.davem@davemloft.net>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
	<1309187108-12715-6-git-send-email-mason@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com
To: mason@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44322 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755535Ab1F2NDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 09:03:34 -0400
In-Reply-To: <1309187108-12715-6-git-send-email-mason@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <mason@myri.com>
Date: Mon, 27 Jun 2011 10:05:05 -0500

> The PCIE capability offset is saved during PCI bus walking.  It will
> remove an unnecessary search in the PCI configuration space if this
> value is referenced instead of reacquiring it.
> 
> Signed-off-by: Jon Mason <mason@myri.com>

Applied.
