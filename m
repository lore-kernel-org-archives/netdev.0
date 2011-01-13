From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] etherdevice.h: Add is_unicast_ether_addr
 function
Date: Thu, 13 Jan 2011 00:24:41 -0800
Message-ID: <1294907081.4114.35.camel@Joe-Laptop>
References: <20110112.234250.10542369.davem@davemloft.net>
	 <1294906496-14950-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, cmetcalf@tilera.com,
	netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3124 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751202Ab1AMIYn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 03:24:43 -0500
In-Reply-To: <1294906496-14950-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-01-13 at 09:14 +0100, Tobias Klauser wrote:
> >From a check for !is_multicast_ether_addr it is not always obvious that
> we're checking for a unicast address. So add this helper function to
> make those code paths easier to read.
>  include/linux/etherdevice.h |   11 +++++++++++
[]
>  /**
> + * is_unicast_ether_addr - Determine if the Ethernet address is unicast
> + * @addr: Pointer to a six-byte array containing the Ethernet address
> + *
> + * Return true if the address is a unicast address.
> + */
> +static inline int is_unicast_ether_addr(const u8 *addr)
> +{
> +	return !is_multicast_ether_addr(addr);
> +}

Can't you simply use is_valid_ether_addr?

I can't think of much reason that a new function for
!multicast without the !is_zero is needed.


