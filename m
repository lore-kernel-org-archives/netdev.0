From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Fri, 28 Aug 2009 15:53:42 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908281553190.17784@gentwo.org>
References: <alpine.DEB.1.10.0908271139450.14277@gentwo.org> <alpine.DEB.1.10.0908271621260.28029@gentwo.org> <alpine.DEB.1.10.0908280948320.3747@gentwo.org> <20090828.122459.245170385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sri@us.ibm.com, dlstevens@us.ibm.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, niv@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:46632 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753109AbZH1UJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 16:09:48 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1A16B82C87B
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 16:11:03 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id tWnnlbccQDkd for <netdev@vger.kernel.org>;
	Fri, 28 Aug 2009 16:10:58 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0FF2582C7B4
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2009 16:10:54 -0400 (EDT)
In-Reply-To: <20090828.122459.245170385.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Aug 2009, David Miller wrote:

> From: Christoph Lameter <cl@linux-foundation.org>
> Date: Fri, 28 Aug 2009 09:53:40 -0400 (EDT)
>
> > Seems though that the qdisc drop count does not flow into the tx_dropped
> > counter for the interface.
>
> And it should not.
>
> The qdisc drops the packet due to flow control, not the hardware
> device.
>
> Device drops are for things like transmission errors on the wire.
>
> If you start incrementing tx_dropped here, people won't be able
> to tell they have a deteriorating cable or bad switch or similar.

?? The patch does not do that. That was extra stuff not covered by the
patch.

