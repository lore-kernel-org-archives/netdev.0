From: David Miller <davem@davemloft.net>
Subject: Re: splice from half-closed socket returning -EAGAIN
Date: Sun, 04 Jan 2009 23:59:46 -0800 (PST)
Message-ID: <20090104.235946.90553420.davem@davemloft.net>
References: <20090104133054.GB16185@xi.wantstofly.org>
	<20090105064728.GE16185@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jens.axboe@oracle.com, ben@zeus.com, opurdila@ixiacom.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51781
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750980AbZAEH7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 02:59:46 -0500
In-Reply-To: <20090105064728.GE16185@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Mon, 5 Jan 2009 07:47:29 +0100

> tcp: don't mask EOF and socket errors on nonblocking splice receive
> 
> Currently, setting SPLICE_F_NONBLOCK on splice from a TCP socket
> results in masking of EOF (RDHUP) and error conditions on the socket
> by an -EAGAIN return.  Move the NONBLOCK check in tcp_splice_read()
> to be after the EOF and error checks to fix this.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

This change looks like the perfect fix for this problem.

I'll apply this, thanks Lennert!
