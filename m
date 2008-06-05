From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: TCP_SKB_CB(skb)->flags = iph->tos ?
Date: Thu, 5 Jun 2008 14:55:00 +0300
Message-ID: <200806051455.00731.opurdila@ixiacom.com>
References: <200805302353.56440.opurdila@ixiacom.com> <20080604.152607.170576716.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4322 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753836AbYFENUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 09:20:15 -0400
In-Reply-To: <20080604.152607.170576716.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>
> That's exactly how I figured it out, I didn't know the answer either,
> but constantly I'm doing simple searches for people and learning the
> code for other people it seems even when I really don't even have
> the time to do so :-/


Apologies, I did not pay attention to my grep output and was under the 
impression that ->flags is only used together with the TCP headers and that 
the ip->tos assignment was never used.

Thanks,
tavi
