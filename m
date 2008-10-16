From: David Miller <davem@davemloft.net>
Subject: Re: TCP RESET after SACK in Kernel 2.6
Date: Thu, 16 Oct 2008 01:40:57 -0700 (PDT)
Message-ID: <20081016.014057.122319113.davem@davemloft.net>
References: <48F6FD29.60904@schwarz-online.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: cs-linuxnet@schwarz-online.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34949
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752733AbYJPIlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 04:41:21 -0400
In-Reply-To: <48F6FD29.60904@schwarz-online.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Schwarz <cs-linuxnet@schwarz-online.com>
Date: Thu, 16 Oct 2008 10:36:57 +0200

[ netdev is the place to post if you actually want a
  knowledgable person to look into your problem ]

> We're running a Debian Linux router with masquerading enabled
> to access a customers site.  The customer connection has a lot of
> packet loss, so we receive some TCP SACK-messages.
> 
> Our old system with Debian 3.1 and Kernel 2.4.xx handled this correctly,
> but after upgrading to Debian 4.0 and Kenrel 2.6.26.5, sometimes the
> SACK-queries are answered with a TCP RESET by the kernel.

Without any example tcpdump traces it is impossible for anyone to help
debug this problem.

> Background question: we have the following setup:
> 
>    client host  ->  router w/ masquerading  ->  target host
> 
> When the target host sends a SACK-query, is it the router's job to
> resend the packets or is this the client host's job?

The end node TCP stack does this, the router doesn't do this.
