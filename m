From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: In udp_flow_src_port use random hash
 value if skb_get_hash fails
Date: Fri, 27 Feb 2015 16:00:20 -0500 (EST)
Message-ID: <20150227.160020.1997065932482750871.davem@davemloft.net>
References: <1424798251-21075-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755246AbbB0VAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 16:00:22 -0500
In-Reply-To: <1424798251-21075-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 24 Feb 2015 09:17:31 -0800

> In the unlikely event that skb_get_hash is unable to deduce a hash
> in udp_flow_src_port we use a consistent random value instead.
> This is specified in GRE/UDP draft section 3.2.1:
> https://tools.ietf.org/html/draft-ietf-tsvwg-gre-in-udp-encap-04
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

This looks fine, applied, thanks Tom.
