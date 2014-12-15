From: "Zhu, Yanjun" <Yanjun.Zhu@windriver.com>
Subject: RE: [PATCH 3/5] e1000e: do not toggle LANPHYPC value bit when PHY
 reset is blocked
Date: Mon, 15 Dec 2014 13:21:43 +0000
Message-ID: <E66F6C44A7A6EA49ABFC80EA526506DF65A865A3@ALA-MBB.corp.ad.wrs.com>
References: <1418632754-16698-1-git-send-email-Yanjun.Zhu@windriver.com>
 <1418632754-16698-4-git-send-email-Yanjun.Zhu@windriver.com>
 <548ECDAC.90207@cogentembedded.com>,<20141215121639.GB28701@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ALLAN, BRUCE" <bruce.w.allan@intel.com>,
	"KIRSHER, JEFFREY" <jeffrey.t.kirsher@intel.com>
To: Willy Tarreau <w@1wt.eu>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:44161 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbaLONWJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 08:22:09 -0500
In-Reply-To: <20141215121639.GB28701@1wt.eu>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Willy

Thanks for your reply.

This patch "[PATCH 3/5] e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked" exists in tag v3.1.

Please follow these steps, this patch can be found:

1. git checkout -f v3.1

2. git log -p drivers/net/e1000e/ich8lan.c

3. search "b7d6e335"

Then we will find this patch.

Best Regards!
Zhu Yanjun

________________________________________
From: Willy Tarreau [w@1wt.eu]
Sent: Monday, December 15, 2014 4:16 AM
To: Sergei Shtylyov
Cc: Zhu Yanjun; netdev@vger.kernel.org; Zhu, Yanjun; ALLAN, BRUCE; KIRSHER, JEFFREY
Subject: Re: [PATCH 3/5] e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked

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