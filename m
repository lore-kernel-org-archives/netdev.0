From: Chris White <chris@logicalelegance.com>
Subject: Re: [PATCH V3 net-next] LISP: Locator/Identifier Separation Protocol
Date: Thu, 19 Jun 2014 21:18:12 -0700
Message-ID: <C5AFF38F-EBF7-45BE-AF17-79259C834AF6@logicalelegance.com>
References: <09FAB6E8-D4D5-4685-BC5E-FF6ACE19383B@logicalelegance.com> <20140619.211111.2189727364823929442.davem@davemloft.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"vermagan@cisco.com" <vermagan@cisco.com>,
	"lojakab@cisco.com" <lojakab@cisco.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.webfaction.com ([74.55.86.74]:40334 "EHLO
	smtp.webfaction.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaFTESR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 00:18:17 -0400
In-Reply-To: <20140619.211111.2189727364823929442.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks David, fixing this now.

-Chris

> On Jun 19, 2014, at 9:11 PM, David Miller <davem@davemloft.net> wrote:
> 
> From: Christopher White <chris@logicalelegance.com>
> Date: Thu, 19 Jun 2014 15:05:53 -0700
> 
>> +static inline struct rtable *ip_route_output_mark(struct net *net,
>> +                    __be32 *saddr, __be32 daddr,
>> +                    u8 ipproto, u8 tos, u32 skb_mark)
> ...
>> +static inline  __be16 udp_tunnel_get_src_port(__u16 port_min, __u16 port_max,
>> +                          struct sk_buff *skb)
> 
> These are not indented properly.
> 
> When a declaration, definition, or invocation of a function spans
> multiple lines, the arguments on the second and subsequent lines
> must begin at the first column after the openning parenthesis on
> the first line.
> 
> You must use the appropriate number of TAB and SPACE characters
> necessary to achieve this.  If you are indenting purely with
> TAB characters, you are doing it wrong.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
