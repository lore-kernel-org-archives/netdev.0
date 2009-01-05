From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: splice from half-closed socket returning -EAGAIN
Date: Mon, 5 Jan 2009 09:03:22 +0100
Message-ID: <20090105080321.GY32491@kernel.dk>
References: <20090104133054.GB16185@xi.wantstofly.org> <20090105064728.GE16185@xi.wantstofly.org> <20090104.235946.90553420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: buytenh@wantstofly.org, ben@zeus.com, opurdila@ixiacom.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([93.163.65.50]:12104 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751225AbZAEIEZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 03:04:25 -0500
Content-Disposition: inline
In-Reply-To: <20090104.235946.90553420.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 04 2009, David Miller wrote:
> From: Lennert Buytenhek <buytenh@wantstofly.org>
> Date: Mon, 5 Jan 2009 07:47:29 +0100
> 
> > tcp: don't mask EOF and socket errors on nonblocking splice receive
> > 
> > Currently, setting SPLICE_F_NONBLOCK on splice from a TCP socket
> > results in masking of EOF (RDHUP) and error conditions on the socket
> > by an -EAGAIN return.  Move the NONBLOCK check in tcp_splice_read()
> > to be after the EOF and error checks to fix this.
> > 
> > Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> 
> This change looks like the perfect fix for this problem.
> 
> I'll apply this, thanks Lennert!

Indeed, you can add my acked-by as well if you want.

-- 
Jens Axboe

