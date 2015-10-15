From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] amd-xgbe: Use system workqueue for device
 restart
Date: Thu, 15 Oct 2015 06:14:04 -0700 (PDT)
Message-ID: <20151015.061404.1632872795924117383.davem@davemloft.net>
References: <20151014173732.11432.15970.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbbJOM56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 08:57:58 -0400
In-Reply-To: <20151014173732.11432.15970.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 14 Oct 2015 12:37:32 -0500

> A previous patch switched from using the system workqueue to the device
> workqueue for various operations. During a device restart the device
> workqueue is flushed so the restart cannot use this workqueue or else
> a deadlock results.  Move the device restart back to using the system
> workqueue.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied, thanks.
