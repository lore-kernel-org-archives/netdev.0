From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/3] bna: Eliminate Small Race Condition Window in
 RX Path
Date: Sat, 17 Sep 2011 00:48:20 -0400 (EDT)
Message-ID: <20110917.004820.39754341376226194.davem@davemloft.net>
References: <1316221608-21392-1-git-send-email-rmody@brocade.com>
	<1316221608-21392-3-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com,
	gkaraje@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab1IQEtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 00:49:23 -0400
In-Reply-To: <1316221608-21392-3-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Fri, 16 Sep 2011 18:06:48 -0700

> Change details:
>  - In a continuous sequence of ifconfig up/down operations, there is a small
>    window of race between bnad_set_rx_mode() and bnad_cleanup_rx() while the
>    former tries to access rx_info->rx & the latter sets it to NULL. This race
>    could lead to bna_rx_mode_set() being called with a NULL (rx_info->rx)
>    pointer and a crash.
>  - Hold bnad->bna_lock while setting / unsetting rx_info->rx in bnad_setup_rx()
>    & bnad_cleanup_rx(), thereby eliminating the race described above.
> 
> Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Applied.
