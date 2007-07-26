From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [PATCH] IPv6: ipv6_addr_type() doesn't know about RFC4193 addresses
Date: Thu, 26 Jul 2007 18:21:59 +0100
Message-ID: <46A8D837.1030400@simon.arlott.org.uk>
References: <18087.57717.495366.413571@zeus.sw.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	Srinivas Akkipeddi <sakkiped@starentnetworks.com>
To: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:37874 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760575AbXGZRWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 13:22:06 -0400
In-Reply-To: <18087.57717.495366.413571@zeus.sw.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26/07/07 00:49, Dave Johnson wrote:
> ipv6_addr_type() doesn't check for 'Unique Local IPv6 Unicast
> Addresses' (RFC4193) and returns IPV6_ADDR_RESERVED for that range.

> +	if ((st & htonl(0xFE000000)) == htonl(0xFC000000))
> +		return (IPV6_ADDR_UNICAST |
> +			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));			/* RFC 4193 */

But ULA's scope isn't global, shouldn't it be IPV6_ADDR_SCOPE_ORGLOCAL ?

-- 
Simon Arlott
