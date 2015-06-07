From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Use disable_irq_nosync from within timer
 function
Date: Sun, 07 Jun 2015 00:21:22 -0700 (PDT)
Message-ID: <20150607.002122.40550681555624508.davem@davemloft.net>
References: <20150605210226.14842.17410.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbbFGHVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 03:21:23 -0400
In-Reply-To: <20150605210226.14842.17410.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Fri, 5 Jun 2015 16:02:26 -0500

> Since the Tx timer function runs in softirq context the driver needs
> to call disable_irq_nosync instead of a disable_irq.
> 
> Reported-by: Josh Stone <jistone@redhat.com>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied, thanks Tom.
