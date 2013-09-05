From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 OOPSen in rtl_rx
Date: Fri, 6 Sep 2013 01:09:30 +0200
Message-ID: <20130905230930.GA25360@electric-eye.fr.zoreil.com>
References: <20130813094314.GW3008@twins.programming.kicks-ass.net>
 <20130813211534.GA5635@electric-eye.fr.zoreil.com>
 <20130814092915.GF24092@twins.programming.kicks-ass.net>
 <20130814095233.GH24092@twins.programming.kicks-ass.net>
 <20130905152026.GB31370@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48167 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757562Ab3IEXKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 19:10:06 -0400
Content-Disposition: inline
In-Reply-To: <20130905152026.GB31370@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra <peterz@infradead.org> :
[...]
> Yay, it triggered..

Bingo.

Can you display the whole descriptor entry (opts1 and opts2) and its
index (cur_rx) when abnormal packets are detected ?
We can always check the packet size but I'd welcome some more specific
pattern in the remaining bits of the descriptor.

Btw, you may try to revert aee77e4accbeb2c86b1d294cd84fec4a12dde3bd
("r8169: use unlimited DMA burst for TX") and see if it changes the
Rx / Tx balance. It would only be a bandaid though.

-- 
Ueimor
