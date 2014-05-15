From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/6] 802154: some cleanups and fixes
Date: Thu, 15 May 2014 15:52:16 -0400 (EDT)
Message-ID: <20140515.155216.1093244691110680877.davem@davemloft.net>
References: <1400082191-16493-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754323AbaEOTwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 15:52:18 -0400
In-Reply-To: <1400082191-16493-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Date: Wed, 14 May 2014 17:43:05 +0200

> This series adds some definitions for 802.15.4 header fields that were missing,
> changes 6lowpan fragmentation to be aware of security headers and fixes
> 802.15.4 datagram socket sendmsg(), which was entirely incompliant to date.
> Also a few minor changes to mac_cb handling, mark a single-use function static,
> and correctly check for EMSGSIZE conditions during wpan_header_create.
> 
> Changes since v1:
>   * rename mac_cb_alloc to mac_cb_init
>   * catch all error cases of sendmsg() instead of only !conn && msg_name
>   * redo 6lowpan fragmentation to not clone lower layer headers

Series applied to net-next, thank you.
