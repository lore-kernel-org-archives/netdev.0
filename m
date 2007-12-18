From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Tue, 18 Dec 2007 11:43:44 +0000
Message-ID: <20071218114344.GB817@gerrit.erg.abdn.ac.uk>
References: <474F7EE8.2040009@cn.fujitsu.com> <474F8255.5060501@cn.fujitsu.com> <20071130111949.GB28277@gerrit.erg.abdn.ac.uk> <20071201015438.GC26895@gondor.apana.org.au> <4753AE07.1040906@cn.fujitsu.com> <20071203113935.GA25124@gondor.apana.org.au> <20071203114912.GA4425@ms2.inr.ac.ru> <20071203115435.GA4202@gondor.apana.org.au> <20071203131723.GA30312@gondor.apana.org.au> <20071215135851.GA29063@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54313 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751776AbXLRLog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 06:44:36 -0500
Content-Disposition: inline
In-Reply-To: <20071215135851.GA29063@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| 
| I didn't hear any objections so here is the patch again.
| 
| [SNMP]: Fix SNMP counters with PREEMPT
| 
I don't feel competent to say whether this is correct, but it seems that
this is going a long way towards resolving older problems with the SNMP
counters.

What I can say is that a year ago, when doing the UDP/-Lite work, I found
that the counters were not accurate, which was due to the double-counting
problem that Wang Chen brought up again.

Resolving this issue was stalled at that time due to the fact that a
counter may be incremented on one CPU and then later decremented on
another.

It looks as if this work is reaching the cause of the problem, which would
be good since the problem propagates to all users of such counters (UDP,
UDP-Lite, and similar MIB counters). So thank you for taking this issue up,
I hope that this will lead to a patch set resolving the counter issues.

Best regards,
Gerrit
