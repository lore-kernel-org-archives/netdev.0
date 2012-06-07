From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: fix checksum bit management on some chips
Date: Thu, 07 Jun 2012 13:07:37 -0700 (PDT)
Message-ID: <20120607.130737.1211760364293640494.davem@davemloft.net>
References: <20120606172036.GA11911@tugrik.mns.mnsspb.ru>
	<20120606130130.5a86f94a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kirr@mns.spb.ru, mlindner@marvell.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45357 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473Ab2FGUHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 16:07:38 -0400
In-Reply-To: <20120606130130.5a86f94a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 6 Jun 2012 13:01:30 -0700

> The newer flavors of Yukon II use a different method for receive
> checksum offload. This is indicated in the driver by the SKY2_HW_NEW_LE
> flag. On these newer chips, the BMU_ENA_RX_CHKSUM should not be set.
> 
> The driver would get incorrectly toggle the bit, enabling the old
> checksum logic on these chips and cause a BUG_ON() assertion. If
> receive checksum was toggled via ethtool.
> 
> Reported-by: Kirill Smelkov <kirr@mns.spb.ru>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied and queued up for -stable.

> Patch against net-next, please apply to net and stable kernels.

Stephen, please don't do this, generate your patches always
against the correct tree even if they are likely to still
apply when generated against the wrong tree.
