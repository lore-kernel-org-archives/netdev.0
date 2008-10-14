From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] enic: Fix build without _HAVE_ARCH_IPV6_CSUM
Date: Mon, 13 Oct 2008 18:51:38 -0700 (PDT)
Message-ID: <20081013.185138.261267537.davem@davemloft.net>
References: <adafxn0p71x.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, scofeldm@cisco.com, netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34770
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754459AbYJNBwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 21:52:02 -0400
In-Reply-To: <adafxn0p71x.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 13 Oct 2008 13:35:22 -0700

> From: Scott Feldman <scofeldm@cisco.com>
> 
> On architectures (such as powerpc) that don't define
> _HAVE_ARCH_IPV6_CSUM, the enic compile fails with
> 
>     drivers/net/enic/enic_main.c: In function 'enic_queue_wq_skb_tso':
>     drivers/net/enic/enic_main.c:575: error: implicit declaration of function 'csum_ipv6_magic'
> 
> Fix this by including <net/ip6_checksum.h>
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>

I already received a fix for this seperately in my tree from
Kamalesh Babulal.
