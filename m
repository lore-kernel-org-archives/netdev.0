From: Ben Collins <benmcollins13@gmail.com>
Subject: Re: [PATCH] net: Add support for handling queueing in hardware
Date: Fri, 22 Mar 2013 11:53:54 -0400
Message-ID: <14243FE7-A0A6-4C0C-AEFB-95F19C8898E3@gmail.com>
References: <FE78128C-01DB-4831-ACBE-BA3E3A428BFC@gmail.com> <20130322.111759.2108472348146991505.davem@davemloft.net> <9AEAD974-4549-475A-AE15-C92523CD2466@gmail.com> <20130322.114159.2303026992656610194.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: afleming@freescale.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:47219 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933516Ab3CVPxx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 11:53:53 -0400
In-Reply-To: <20130322.114159.2303026992656610194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 22, 2013, at 11:41 AM, David Miller <davem@davemloft.net> wrote:

> From: Ben Collins <benmcollins13@gmail.com>
> Date: Fri, 22 Mar 2013 11:39:20 -0400
> 
>> If your company had hardware going to production, you'd want it
>> supported in mainline too, I suspect.
> 
> But never against the wishes of the author of the code.
> 
> This has firm and strict precedence, for example one of the
> implementations block layer encryption was not wanted to be merged by
> the author, and Linus reverted it.
> 
> So if the person who wrote the code doesn't want it upstream, you can't
> bypass them against their wishes, ever.  It's their code not your's.

They never made such a statement. The commit (which is publicly available in Freescale's git repo) makes no mention of it being "good enough for our SDK, but don't send upstream". Freescale wants this upstream, but doesn't have the resources because they are embedded focused and gear more toward SDKs to support their SoCs (currently that means a 3.0.x kernel).

Don't accuse me of something I didn't do. Also, if there's a patch that makes my hardware work, but I can't use it because (even though it's open source licensed) the author doesn't want it in mainline, then that is effectively squatting.

We are a hardware company. We've been provided with a driver for the platform we designed by the SoC vendor. It's GPL licensed. We've attempted to get this done by them, but they haven't been able to, so we are exercising prudence and making sure our platform is supported in mainline. I don't see where that's any different than tons of other patches that go into the kernel.

If it makes everyone feel better, I'll limit attribution in the patches to just an Originally-By: line.

--
Servergy  : http://www.servergy.com/
SwissDisk : http://www.swissdisk.com/
Ubuntu    : http://www.ubuntu.com/
My Blog   : http://ben-collins.blogspot.com/
