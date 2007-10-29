From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [UDP6]: Restore sk_filter optimisation
Date: Mon, 29 Oct 2007 15:41:50 +0900 (JST)
Message-ID: <20071029.154150.106134742.yoshfuji@linux-ipv6.org>
References: <20070306012010.GA25763@gondor.apana.org.au>
	<20071029153320.d2c00f62.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: mitch@linux.vnet.ibm.com, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:36744 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbXJ2Glk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 02:41:40 -0400
In-Reply-To: <20071029153320.d2c00f62.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20071029153320.d2c00f62.mitch@linux.vnet.ibm.com> (at Mon, 29 Oct 2007 15:33:20 +0900), Mitsuru Chinen <mitch@linux.vnet.ibm.com> says:

> Hello Herbert,
> 
> Let me ask a question about this patch.
> After this patch was applied, 2 of the protocol stack behaviors were
> changed when it receives a UDP datagram with broken checksum:
> 
>  1. udp6InDatagrams is incremented instead of udpInErrors
>  2. In userland, recvfrom() replies an error with EAGAIN.
>     recvfrom() wasn't aware of such a packet before.
> 
> Are these changes intentional?

And, we're not sure how much the "optimization"'s benefit is.
It is even worse when we are handling multicast packets.

--yoshfuji
