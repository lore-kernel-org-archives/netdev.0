From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] batman-adv: fix skb->data assignment
Date: Tue, 19 Jun 2012 14:49:41 -0700 (PDT)
Message-ID: <20120619.144941.1042145718266158529.davem@davemloft.net>
References: <1340133999-26838-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	stable@vger.kernel.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155Ab2FSVtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 17:49:42 -0400
In-Reply-To: <1340133999-26838-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Tue, 19 Jun 2012 21:26:39 +0200

> skb_linearize(skb) possibly rearranges the skb internal data and then changes
> the skb->data pointer value. For this reason any other pointer in the code that
> was assigned skb->data before invoking skb_linearise(skb) must be re-assigned.
> 
> In the current tt_query message handling code this is not done and therefore, in
> case of skb linearization, the pointer used to handle the packet header ends up
> in pointing to free'd memory.
> 
> This bug was introduced by a73105b8d4c765d9ebfb664d0a66802127d8e4c7
> (batman-adv: improved client announcement mechanism)
> 
> Signed-off-by: Antonio Quartulli <ordex@autistici.org>
> Cc: <stable@vger.kernel.org>

Applied.

Submit things properly in the future so you don't give me unnecessary
merge hassles like this again.
