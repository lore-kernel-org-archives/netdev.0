From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] eth: Declare an optimized compare_ether_addr_64bits()
 function
Date: Sun, 23 Nov 2008 15:45:54 -0800 (PST)
Message-ID: <20081123.154554.255301279.davem@davemloft.net>
References: <4927B275.1030407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40627
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750818AbYKWXpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2008 18:45:54 -0500
In-Reply-To: <4927B275.1030407@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 22 Nov 2008 08:19:17 +0100

> This patch implements a compare_ether_addr_64bits() function, that
> handles the case of x86 cpus, but might be used on other arches as
> well, if their potential misaligned long word reads are not
> expensive.

We have a test for this, HAVE_EFFICIENT_UNALIGNED_ACCESS

Please use that instead of CONFIG_X86 and I'll apply this
to net-next-2.6

Thanks!
