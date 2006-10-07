From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 01/02] net/ipv6: seperate sit driver to extra module
Date: Sat, 7 Oct 2006 01:05:16 -0400
Message-ID: <20061007010517.3b9db240.billfink@mindspring.com>
References: <20061006093402.GA12460@zlug.org>
	<20061006.215935.92667295.yoshfuji@linux-ipv6.org>
	<20061006151556.GA15637@zlug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:3303 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net") by vger.kernel.org with ESMTP
	id S1751693AbWJGFFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Oct 2006 01:05:41 -0400
To: Joerg Roedel <joro-lkml@zlug.org>
In-Reply-To: <20061006151556.GA15637@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 6 Oct 2006 17:15:56 +0200, Joerg Roedel wrote:

> +config IPV6_SIT
> +	tristate "IPv6: IPv6-in-IPv4 tunnel (SIT driver)"
> +	depends on IPV6
> +	default y
> +	---help---
> +	  Tunneling means encapsulating data of one protocol type within
> +	  another protocol and sending it over a channel that understands the
> +	  encapsulating protocol. This driver implements encapsulation of IPv6
> +	  into IPv4 packets. This is useful if you want to connect two IPv6
> +	  networks over an IPv4-only path.
> +
> +	  Saying M here will produce a module called sit.ko. If unsure, say N.

>From a user perspective, I believe it should say "If unsure, say Y".
The unsure case for the unsure user should be the case that works for
the broadest possible usage spectrum, which would be the 'Y' case.
To put it another way, if you pick 'Y' and don't really need it, the
only downside is wasting some memory.  But if you pick 'N' and actually
did need it, previously working IPv6 networking would no longer work.
I believe the default setting should match the unsure recommendation.

						-Bill
