From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Sat, 10 Jul 2010 12:30:11 -0700 (PDT)
Message-ID: <20100710.123011.260095467.davem@davemloft.net>
References: <1278695580.2696.55.camel@edumazet-laptop>
	<AANLkTil39xHOhcdAo4h_jWtx_UuYdFHGdQVAdwPMd7QJ@mail.gmail.com>
	<1278742649.2538.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felipewd@gmail.com, kaber@trash.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58480
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751102Ab0GJT34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 15:29:56 -0400
In-Reply-To: <1278742649.2538.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 10 Jul 2010 08:17:29 +0200

> Strange thing with your crash report is CR2 value, with unexpected value
> of 000000000b388000 while RAX value is dce8dce85d415d41
> 
> Faulting instruction is :
> 
> 48 83 b8 b0 00 00 00 00   cmpq   $0x0,0xb0(%rax)
> 
> So I would have expected CR2 being RAX+0xb0, but its not.

It could be corruption from elsewhere.  Those last four hex
digits (0x5d415d41) are "]A]A" in ascii, but that could just
be coincidence.

