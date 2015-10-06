From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] amd-xgbe: Check for successful buffer allocation
 before use
Date: Mon, 05 Oct 2015 23:31:13 -0700 (PDT)
Message-ID: <20151005.233113.840751866053468766.davem@davemloft.net>
References: <20151005155103.10841.38132.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44717 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbbJFGPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 02:15:31 -0400
In-Reply-To: <20151005155103.10841.38132.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Mon, 5 Oct 2015 10:51:03 -0500

> The kasprintf function can return NULL if the allocation fails. Check for
> successful allocation before attempting to use the returned buffer.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied, thanks.
