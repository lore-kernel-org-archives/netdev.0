From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 3/5] e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked
Date: Mon, 15 Dec 2014 13:16:39 +0100
Message-ID: <20141215121639.GB28701@1wt.eu>
References: <1418632754-16698-1-git-send-email-Yanjun.Zhu@windriver.com> <1418632754-16698-4-git-send-email-Yanjun.Zhu@windriver.com> <548ECDAC.90207@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>, netdev@vger.kernel.org,
	Zhu Yanjun <Yanjun.Zhu@windriver.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2685 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750714AbaLOMQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2014 07:16:45 -0500
Content-Disposition: inline
In-Reply-To: <548ECDAC.90207@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, Dec 15, 2014 at 03:01:48PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 12/15/2014 11:39 AM, Zhu Yanjun wrote:
> 
> >2.6.x kernels require a similar logic change as commit b7d6e335
> >[e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked]
> >introduces for newer kernels.
> 
>    Hm, so is this patch to 2.6.x-stable kernels or a recent kernel?
> If the former, you should follow the rules in 
> Documentation/stable_kernel_rules.txt.

I don't see anything there that does not comply with the rules. This
patchset looks fine and acceptable to me, I'll just wait a bit so that
if either Jeff or Bruce rejects it I respect their wish.

However you just made me realize that I can't find commit b7d6e335.
Zhu, please double-check that this commit (or an equivalent) was merged
upstream, *this* it a prerequisite for going into -stable.

> >When PHY reset is intentionally blocked on 82577/8/9, do not toggle the
> >LANPHYPC value bit (essentially performing a hard power reset of the
> >device) otherwise the PHY can be put into an unknown state.
> 
> >Cleanup whitespace in the same function.
> 
> >[yanjun.zhu: whitespace remains unchanged]
> 
> >Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> 
>    So, is this your patch, or Bruce's? If the latter, you should add:
> 
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> at the start of the change log.
>
> >Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> >Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>

The case where a commit gets backported is always ambiguous, especially
when the context changes a lot. I'm personally in favor of keeping the
original signed-of-by chain related to the original fix, and adding some
text between it and the backporter's s-o-b indicating that the changes
were, so that original authors do not get blamed for mistakes.

Best regards,
Willy
