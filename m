From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH] ks8851: Cancel any pending IRQ work
Date: Fri, 13 Apr 2012 11:32:21 -0700
Message-ID: <4F887135.5080005@codeaurora.org>
References: <1334249091-7605-1-git-send-email-mjr@cs.wisc.edu> <4F8738EB.2060806@codeaurora.org> <005701cd18eb$aaa0ab90$ffe202b0$@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Ben Dooks <ben-linux@fluff.org>
To: Matt Renzelmann <mjr@cs.wisc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:18853 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432Ab2DMSch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 14:32:37 -0400
In-Reply-To: <005701cd18eb$aaa0ab90$ffe202b0$@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/12 13:34, Matt Renzelmann wrote:
> I agree on all counts -- the patch is buggy, though it does at least "shrink"
> the window of vulnerability.  Frankly, I don't believe I'm qualified to write an
> appropriate patch for this driver, at least without spending considerably more
> time on it.
>
> FWIW, I found this problem with a new driver-testing tool we've developed called
> SymDrive, and my goal is primarily to determine if the bug is real or not.  The
> tool is imperfect and we are trying to validate its operation.

The bug is real if your interrupt controller is broken :-) One could
argue that it's outside the scope of this driver to handle broken
interrupt controllers or buggy genirq code, but being defensive sounds
like a good idea.

>
> That said, if there is an issue here, and we can come up with an appropriate
> fix, then I'd be happy to write a patch for it.
>

I'll see what I can do in the next few days about the deadlock I mentioned.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
