From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH][XFRM]: nlmsg length not computed correctly in the presence of subpolicies
Date: Sat, 18 Nov 2006 18:08:42 +0900
Message-ID: <20061118180712.A7A4.NAKAM@linux-ipv6.org>
References: <1163771311.5107.24.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:4033 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1756243AbWKRJIi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Nov 2006 04:08:38 -0500
To: hadi@cyberus.ca
In-Reply-To: <1163771311.5107.24.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Nov 2006 08:48:31 -0500
jamal <hadi@cyberus.ca> wrote:

> Another one in the same spirit as before. Compiles. I dont have
> a good test case, but looks right.
> Nakamura-san please ACK and Dave (as before this goes in as a bug-fix).

Acked-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

I've tested with your patch and the result is fine.

However, unlike the add/delete XFRM policy case pointed by Jamal
as the previous patch, I don't see the error without this patch on my
environment about acqiure.
(Maybe, does acquire path happen to make some buffer for policy type
since the structures is not aligned cleanly?)

..Anyway, the fix is correct for me. David, please apply it, too.


> [XFRM]: nlmsg length not computed correctly in the presence of subpolicies
> 
> I actually dont have a test case for these; i just found them by
> inspection. Refer to patch "[XFRM]: Sub-policies broke policy events"
> for more info
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
> 
> ---
> commit c3d793454ab2a36c2d618d226d7de975ab9b7570
> tree 26198ba84d85317b4f1b54c0e10c220dbe0d97da
> parent b53ec68c276ac1d879759de130620a72254cb969
> author Jamal Hadi Salim <hadi@cyberus.ca> Fri, 17 Nov 2006 08:39:52 -0500
> committer Jamal Hadi Salim <hadi@jzny2.(none)> Fri, 17 Nov 2006 08:39:52 -0500


-- 
Masahide NAKAMURA

