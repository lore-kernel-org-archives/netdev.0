From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC, PATCH] IPV6 : add 64 bits components in struct in6_addr to speedup ipv6_addr_equal() & ipv6_addr_any()
Date: 30 Apr 2007 23:34:20 +0200
Message-ID: <p73bqh5zgv7.fsf@bingen.suse.de>
References: <20070430162851.ca3c7869.dada1@cosmosbay.com>
	<20070430.121029.21927349.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:53694 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946799AbXD3UhI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 16:37:08 -0400
In-Reply-To: <20070430.121029.21927349.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> 
> Unfortunately, as mentioned elsewhere, we're only able to assume
> 32-bit alignment of ipv6 packet headers and that isn't likely to
> change any time soon.

On x86 it would be fine at least -- unaligned access is cheap. I believe
the same is true for POWER4/5/s390x. Should it be made conditional perhaps?

-Andi
