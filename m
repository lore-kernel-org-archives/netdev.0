From: Paul Mackerras <paulus@samba.org>
Subject: Re: Fw: kernel oops at ppp
Date: Sun, 1 Apr 2007 12:24:35 +1000
Message-ID: <17935.6115.518506.249844@cargo.ozlabs.ibm.com>
References: <20070331121633.858312f1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephan Helas <shelas@web.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45798 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751280AbXDACYn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Mar 2007 22:24:43 -0400
In-Reply-To: <20070331121633.858312f1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton writes:

> From: Stephan Helas <shelas@web.de>
> To: linux-kernel@vger.kernel.org
> Subject: kernel oops at ppp
> 
> 
> Hello,
> 
> i got oops on unsing UMTS - hsdpa card merlin xu870 using ppp.

What is a "UMTS - hsdpa card merlin xu870"?

At a guess I would say that whatever ppp channel code is being used
hasn't left any header room on a received skb, but without knowing
what ppp channel module is being used it's hard to say.

Paul.
