From: Meelis Roos <mroos@linux.ee>
Subject: Re: [PATCH] warning in SCTP
Date: Thu, 2 Nov 2006 11:22:17 +0200 (EET)
Message-ID: <Pine.SOC.4.61.0611021119560.1919@math.ut.ee>
References: <Pine.SOC.4.61.0611020925530.1919@math.ut.ee>
 <20061102.001643.30183952.davem@davemloft.net> <20061102.003953.55508453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, sri@us.ibm.com,
	lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:8636 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1752023AbWKBJWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 04:22:30 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061102.003953.55508453.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Actually, I'm backing this one out, it creates new warnings because
> callers of this function pass in a "const" pointer.

Yes, it now seems it's not so simple. Marking it non-const there would 
mark the it non-const in the whole family of sctp_state_fn_t and I'm not 
sure that's the best thing to do. I guess the maintainer has better 
bases for deciding what to do about it.

-- 
Meelis Roos (mroos@linux.ee)
