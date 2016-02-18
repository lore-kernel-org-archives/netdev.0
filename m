From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] iptunnel: scrub packet in
 iptunnel_pull_header
Date: Thu, 18 Feb 2016 14:35:26 -0500 (EST)
Message-ID: <20160218.143526.889513658366375505.davem@davemloft.net>
References: <cover.1455790645.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@kernel.org, linville@tuxdriver.com,
	pshelar@nicira.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947019AbcBRTfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 14:35:52 -0500
In-Reply-To: <cover.1455790645.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu, 18 Feb 2016 11:22:48 +0100

> As every IP tunnel has to scrub skb on decapsulation, iptunnel_pull_header
> tried to do that and open coded part of skb_scrub_packet. Various tunneling
> protocols (VXLAN, Geneve) then called full skb_scrub_packet on their own,
> duplicating part of the scrubbing already done.
> 
> Consolidate the code, calling skb_scrub_packet from iptunnel_pull_header.
> This will allow additional cleanups in VXLAN code, as the packet is scrubbed
> early during rx processing after this patchset and VXLAN can start filling
> out skb fields earlier.
> 
> The full picture of vxlan cleanup patches can be seen at:
> https://github.com/jbenc/linux-vxlan/commits/master

Very nice cleanup, patch applied.
