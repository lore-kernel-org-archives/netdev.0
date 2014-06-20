From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next] LISP: Locator/Identifier Separation
 Protocol
Date: Thu, 19 Jun 2014 21:11:11 -0700 (PDT)
Message-ID: <20140619.211111.2189727364823929442.davem@davemloft.net>
References: <09FAB6E8-D4D5-4685-BC5E-FF6ACE19383B@logicalelegance.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vermagan@cisco.com, lojakab@cisco.com
To: chris@logicalelegance.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46355 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbaFTELP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 00:11:15 -0400
In-Reply-To: <09FAB6E8-D4D5-4685-BC5E-FF6ACE19383B@logicalelegance.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christopher White <chris@logicalelegance.com>
Date: Thu, 19 Jun 2014 15:05:53 -0700

> +static inline struct rtable *ip_route_output_mark(struct net *net,
> +					__be32 *saddr, __be32 daddr,
> +					u8 ipproto, u8 tos, u32 skb_mark)
 ...
> +static inline  __be16 udp_tunnel_get_src_port(__u16 port_min, __u16 port_max,
> +					      struct sk_buff *skb)

These are not indented properly.

When a declaration, definition, or invocation of a function spans
multiple lines, the arguments on the second and subsequent lines
must begin at the first column after the openning parenthesis on
the first line.

You must use the appropriate number of TAB and SPACE characters
necessary to achieve this.  If you are indenting purely with
TAB characters, you are doing it wrong.
