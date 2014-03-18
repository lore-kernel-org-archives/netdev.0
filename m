From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ieee802154: properly unshare skbs in
 ieee802154 *_rcv functions
Date: Tue, 18 Mar 2014 16:02:30 -0400 (EDT)
Message-ID: <20140318.160230.2183096530710923639.davem@davemloft.net>
References: <1395070888-1130-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55243 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756656AbaCRUCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 16:02:32 -0400
In-Reply-To: <1395070888-1130-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Date: Mon, 17 Mar 2014 16:41:28 +0100

> ieee802154 sockets do not properly unshare received skbs, which leads to
> panics (at least) when they are used in conjunction with 6lowpan, so
> run skb_share_check on received skbs.
> 6lowpan also contains a use-after-free, which is trivially fixed by
> replacing the inlined skb_share_check with the explicit call.
> 
> Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>

Applied, thank you.
