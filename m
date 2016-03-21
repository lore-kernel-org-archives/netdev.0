From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] vxlan: fix too large pskb_may_pull with remote
 checksum
Date: Mon, 21 Mar 2016 13:32:40 -0400 (EDT)
Message-ID: <20160321.133240.1118095343751751289.davem@davemloft.net>
References: <ea0a247890814c5546b6b4490eab79478df34124.1458578979.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48831 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756670AbcCURcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 13:32:43 -0400
In-Reply-To: <ea0a247890814c5546b6b4490eab79478df34124.1458578979.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Mon, 21 Mar 2016 17:50:05 +0100

> vxlan_remcsum is called after iptunnel_pull_header and thus the skb has
> vxlan header already pulled. Don't include vxlan header again in the
> calculation.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied, thanks.
