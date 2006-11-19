From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM]: nlmsg length not computed correctly in the
 presence of subpolicies
Date: Sun, 19 Nov 2006 17:55:44 -0500 (EST)
Message-ID: <20061119.175544.59672238.davem@davemloft.net>
References: <1163771311.5107.24.camel@jzny2>
	<20061118180712.A7A4.NAKAM@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:12758 "EHLO localhost")
	by vger.kernel.org with ESMTP id S933649AbWKSWzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Nov 2006 17:55:44 -0500
To: nakam@linux-ipv6.org
In-Reply-To: <20061118180712.A7A4.NAKAM@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Sat, 18 Nov 2006 18:08:42 +0900

> On Fri, 17 Nov 2006 08:48:31 -0500
> jamal <hadi@cyberus.ca> wrote:
> 
> > Another one in the same spirit as before. Compiles. I dont have
> > a good test case, but looks right.
> > Nakamura-san please ACK and Dave (as before this goes in as a bug-fix).
> 
> Acked-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> I've tested with your patch and the result is fine.
> 
> However, unlike the add/delete XFRM policy case pointed by Jamal
> as the previous patch, I don't see the error without this patch on my
> environment about acqiure.
> (Maybe, does acquire path happen to make some buffer for policy type
> since the structures is not aligned cleanly?)
> 
> ..Anyway, the fix is correct for me. David, please apply it, too.

Applied, thanks.
