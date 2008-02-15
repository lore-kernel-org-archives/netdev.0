From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][AX25] mkiss: ax_bump() locking fix
Date: Fri, 15 Feb 2008 10:53:23 -0500
Message-ID: <47B5B573.6050209@garzik.org>
References: <20080206074529.GC4496@ff.dom.local> <20080213111758.GA2867@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Jann Traschewski <jann@gmx.de>,
	Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52910 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757009AbYBOPx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 10:53:29 -0500
In-Reply-To: <20080213111758.GA2867@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Hi,
> 
> This is unchanged patch previously sent here for testing.
> I think it should be applied.
> 
> Thanks,
> Jarek P.
> 
> ---------------->
> 
> Subject: [PATCH][AX25] mkiss: ax_bump() locking fix
> 
> According to one of OOPSes reported by Jann softirq can break
> while skb is prepared for netif_rx. The report isn't complete,
> so the real reason of the later bug could be different, but
> IMHO this locking break in ax_bump is unsafe and unnecessary.
> 
> Reported-and-tested-by: Jann Traschewski <jann@gmx.de>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> ---
> 
>  drivers/net/hamradio/mkiss.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)

applied


