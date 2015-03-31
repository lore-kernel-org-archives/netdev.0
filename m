From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] netlink: access functions for IP address
 attributes
Date: Tue, 31 Mar 2015 13:58:56 -0400 (EDT)
Message-ID: <20150331.135856.1727900367681294283.davem@davemloft.net>
References: <cover.1427639592.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, jchapman@katalix.com,
	paul@paul-moore.com, pshelar@nicira.com, johannes@sipsolutions.net,
	pablo@netfilter.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49071 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012AbbCaR67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 13:58:59 -0400
In-Reply-To: <cover.1427639592.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Sun, 29 Mar 2015 16:59:22 +0200

> There are many places that read or write IP addresses to netlink attributes.
> With IPv6 addresses, every such place currently has to use generic nla_put
> and nla_memcpy. Implementing IPv6 address access functions simplify things
> and makes the code more intelligible. IPv4 address access functions has
> lesser value but it would be better to be consistent between IPv6 and IPv4
> and they still serve as documentation.
> 
> The conversion is straightforward and the resulting patches are not that
> large, thus I kept all the changes in the patches that introduce the access
> functions. If anyone prefers to split the definition of access functions and
> the conversion and/or break it out by network protocols, please let me know.
> 
> While doing the conversion, I came across ugly typecasting in
> inetpeer_addr_base and xfrm_address_t when dealing with IPv6 addresses.
> Instead of introducing more of this, I cleaned it up. Those are the first
> two patches, serving as a prerequisite to the latter two.

Looks good, series applied, thanks Jiri.
