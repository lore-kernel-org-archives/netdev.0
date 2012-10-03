From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] 8021q: fix mac_len recomputation in vlan_untag()
Date: Tue, 02 Oct 2012 22:46:31 -0400 (EDT)
Message-ID: <20121002.224631.2146684475718664660.davem@davemloft.net>
References: <1349194457-31623-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946Ab2JCCqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 22:46:33 -0400
In-Reply-To: <1349194457-31623-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Tue,  2 Oct 2012 18:14:17 +0200

> skb_reset_mac_len() relies on the value of the skb->network_header pointer,
> therefore we must wait for such pointer to be recalculated before computing
> the new mac_len value.
> 
> Signed-off-by: Antonio Quartulli <ordex@autistici.org>

Applied and queued up for -stable, thanks!
