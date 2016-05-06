From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qede: prevent chip hang when increasing
 channels
Date: Fri, 06 May 2016 15:51:58 -0400 (EDT)
Message-ID: <20160506.155158.1383422608405482582.davem@davemloft.net>
References: <1462422916-25584-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com
To: sudarsana.kalluru@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758275AbcEFTwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 15:52:00 -0400
In-Reply-To: <1462422916-25584-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Date: Thu, 5 May 2016 00:35:16 -0400

> qede requires qed to provide enough resources to accommodate 16 combined
> channels, but that upper-bound isn't actually being enforced by it.
> Instead, qed inform back to qede how many channels can be opened based on
> available resources - but that calculation doesn't really take into account
> the resources requested by qede; Instead it considers other FW/HW available
> resources.
> 
> As a result, if a user would increase the number of channels to more than
> 16 [e.g., using ethtool] the chip would hang.
> 
> This change increments the resources requested by qede to 64 combined
> channels instead of 16; This value is an upper bound on the possible
> available channels [due to other FW/HW resources].
> 
> Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied.
