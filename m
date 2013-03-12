From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Allow for backward compatibility with
 new VPD scheme.
Date: Tue, 12 Mar 2013 05:37:44 -0400 (EDT)
Message-ID: <20130312.053744.349333966792167526.davem@davemloft.net>
References: <1362749729-4532-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, dm@chelsio.com,
	abhishek@chelsio.com, santosh@chelsio.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754901Ab3CLJhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 05:37:32 -0400
In-Reply-To: <1362749729-4532-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Fri,  8 Mar 2013 19:05:29 +0530

> From: Santosh Rastapur <santosh@chelsio.com>
> 
> New scheme calls for 3rd party VPD at offset 0x0 and Chelsio VPD at offset
> 0x400 of the function.  If no 3rd party VPD is present, then a copy of
> Chelsio's VPD will be at offset 0x0 to keep in line with PCI spec which
> requires the VPD to be present at offset 0x0.
> 
> Signed-off-by: Santosh Rastapur <santosh@chelsio.com>
> Signed-off-by: Vipul Pandya <vipul@chelsio.com>

Applied to 'net'.
