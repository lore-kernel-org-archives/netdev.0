From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gre: do not pull header in ICMP error processing
Date: Mon, 02 May 2016 00:20:57 -0400 (EDT)
Message-ID: <20160502.002057.896629867341178886.davem@davemloft.net>
References: <666d05a8cff4a89ce4fd77810902246aa3e7a13f.1461965458.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbcEBEVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 00:21:01 -0400
In-Reply-To: <666d05a8cff4a89ce4fd77810902246aa3e7a13f.1461965458.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri, 29 Apr 2016 23:31:32 +0200

> iptunnel_pull_header expects that IP header was already pulled; with this
> expectation, it pulls the tunnel header. This is not true in gre_err.
> Furthermore, ipv4_update_pmtu and ipv4_redirect expect that skb->data points
> to the IP header.
> 
> We cannot pull the tunnel header in this path. It's just a matter of not
> calling iptunnel_pull_header - we don't need any of its effects.
> 
> Fixes: bda7bb463436 ("gre: Allow multiple protocol listener for gre protocol.")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied and queued up for -stable, thanks Jiri.
