From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Wed, 3 Oct 2007 14:23:58 -0700
Message-ID: <20071003212358.GF6183@bitmover.com>
References: <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <alpine.LFD.0.999.0710021146580.3579@woody.linux-foundation.org> <20071002.133322.52193802.davem@davemloft.net> <20071002212132.GF29944@bitmover.com> <20071003211321.GA13583@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lm@bitmover.com, David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, herbert@gondor.apana.org.au,
	wscott@bitmover.com, netdev@vger.kernel.org
To: Pekka Pietikainen <pp@ee.oulu.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:45820 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758955AbXJCVX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 17:23:59 -0400
Content-Disposition: inline
In-Reply-To: <20071003211321.GA13583@ee.oulu.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> A few notes to the discussion. I've seen one e1000 "bug" that ended up being
> a crappy AMD pre-opteron SMP chipset with a totally useless PCI bus
> implementation, which limited performance quite a bit-totally depending on
> what you plugged in and in which slot. 10e milk-and-bread-store 
> 32/33 gige nics actually were better than server-class e1000's 
> in those, but weren't that great either.

That could well be my problem, this is a dual processor (not core) athlon
(not opteron) tyan motherboard if I recall correctly.

> Check your interrupt rates for the interface. You shouldn't be getting
> anywhere near 1 interrupt/packet. If you are, something is badly wrong :).

The acks (because I'm sending) are about 1.5 packets/interrupt.
When this box is receiving it's moving about 3x ass much data
and has a _lower_ (absolute, not per packet) interrupt load.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
