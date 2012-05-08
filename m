From: David Miller <davem@davemloft.net>
Subject: [README] net --> net-next merge
Date: Mon, 07 May 2012 23:41:13 -0400 (EDT)
Message-ID: <20120507.234113.2269441747611427613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linville@tuxdriver.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757751Ab2EHDo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 23:44:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just merged net into net-next, there were two major conflicts.

1) The known iwlwifi conflict due to the skb->truesize bug fix in
   'net'.

   I used the conflict resolution posted by John and later by Stephen
   when he resolved it for -next.

   John, please double-check my work.

2) drivers/net/ethernet/intel/e1000e/param.c got a conflict in
   the code which validates adapter->itr settings.

   The net-next side looked more sophisticated so that's what I
   used.

   Jeff, please double-check and send me fixup patches if necessary.

Thanks.
