From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tun_dst: Fix potential NULL dereference
Date: Wed, 04 Nov 2015 21:59:51 -0500 (EST)
Message-ID: <20151104.215951.1250680297515353242.davem@davemloft.net>
References: <1446641389-26183-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756175AbbKEC7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 21:59:53 -0500
In-Reply-To: <1446641389-26183-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed,  4 Nov 2015 13:49:49 +0100

> In tun_dst_unclone() the return value of skb_metadata_dst() is checked
> for being NULL after it is dereferenced. Fix this by moving the
> dereference after the NULL check.
> 
> Found by the Coverity scanner (CID 1338068).
> 
> Fixes: fc4099f17240 ("openvswitch: Fix egress tunnel info.")
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied and queued up for -stable, thanks.
