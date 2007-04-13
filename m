From: David Miller <davem@davemloft.net>
Subject: Re: kernel BUG at net/core/skbuff.c in linux-2.6.21-rc6
Date: Fri, 13 Apr 2007 16:16:35 -0700 (PDT)
Message-ID: <20070413.161635.26523891.davem@davemloft.net>
References: <9a8748490704100425t34ebafcdq866a923df80b9aca@mail.gmail.com>
	<19061b0b0704112218j13688c16xc755d66147f8fe6a@mail.gmail.com>
	<461DC70B.4000500@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: poemann@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51685
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030876AbXDMXQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 19:16:34 -0400
In-Reply-To: <461DC70B.4000500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 12 Apr 2007 07:43:39 +0200

> Bartek wrote:
> > Hopefully, this time it my bug report should be ok :):
> > 
> > Apr 11 23:53:38 localhost pppd[31289]: rcvd [proto=0x7689] e1 cd 33 f6
> > fd f7 52 e6 58 c9 73 98 bc ff ad d5 b5 a3 e5 d9 1e 77 76 0a 1c 87 59
> > bf 44 cc ac 3b ...
> > Apr 11 23:53:38 localhost pppd[31289]: Unsupported protocol 0x7689 received
> > Apr 11 23:53:38 localhost pppd[31289]: sent [LCP ProtRej id=0x9 76 89
> > e1 cd 33 f6 fd f7 52 e6 58 c9 73 98 bc ff ad d5 b5 a3 e5 d9 1e 77 76
> > 0a 1c 87 59 bf 44 cc ...]
> > Apr 11 23:53:38 localhost pppd[31289]: rcvd [proto=0xda7d] 15 19 45 3c
> > e0 ac 44 92 3b c4 8e 75 6b b8 4a 9f 4a 3a 22 63 d3 a1 56 98 47 62 bc
> > cd a6 8e d5 77 ...
> > Apr 11 23:53:38 localhost pppd[31289]: Unsupported protocol 0xda7d received
> > Apr 11 23:53:38 localhost pppd[31289]: sent [LCP ProtRej id=0xa da 7d
> > 15 19 45 3c e0 ac 44 92 3b c4 8e 75 6b b8 4a 9f 4a 3a 22 63 d3 a1 56
> > 98 47 62 bc cd a6 8e ...]
> > Apr 11 23:53:40 localhost kernel: skb_under_panic: text:f8c62c0e
> > len:291 put:1 head:ddc94800 data:ddc947ff tail:ddc94922 end:ddc94e00
> > dev:<NULL>
> 
> 
> It seems we fail to reserve enough headroom for the case
> buf[0] == PPP_ALLSTATIONS and buf[1] != PPP_UI.
> 
> Can you try this patch please?

Any confirmation of this fix yet?
