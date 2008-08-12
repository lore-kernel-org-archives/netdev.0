From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Tue, 12 Aug 2008 09:46:17 +0200
Message-ID: <200808120946.19459.thomas.jarosch@intra2net.com>
References: <Pine.LNX.4.64.0808071422360.4551@wrl-59.cs.helsinki.fi> <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi> <20080811.144421.234396007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, billfink@mindspring.com,
	fragabr@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	sr@securenet.de, netfilter-devel@vger.kernel.org,
	kadlec@blackhole.kfki.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from re01.intra2net.com ([82.165.28.202]:41640 "EHLO
	re01.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbYHLHqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 03:46:23 -0400
In-Reply-To: <20080811.144421.234396007.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 11. August 2008 23:44:21 David Miller wrote:
> Trying to come up with a signature for this bogus stuff is both time
> consuming and having a risk of false positives.  And I really question
> whether this thing is worth it.
>
> The sane thing to do in this case is to declare the box inoperative
> and that it needs to be fixed to avoid this behavior.
>
> Any reasonable congestion control scheme is going to run into problems
> trying to react to the packet patterns this thing creates.  It is
> therefore not really limited to FRTO so it really shouldn't be treated
> like an FRTO problem even though it shows up more pronounced when
> FRTO is enabled.

David, I agree with you, though I'm not sure about the end user experience:

The kernel is an early adopter of FRTO and will be bitten by bugs of other
TCP implementations like we've experienced. I guess most affected users
just see stalled or slow connections and won't have the time or knowledge
to debug this. A proper warning could help them and the kernel
developers to get this issue solved as quickly as possible.

We called the hotline of the ISP several times and they always claimed
sending big mails with Outlook/Windows works, so it must be linux's fault.
That view of things is totally biased, but it's something I want to make sure
people can't get away with easily :-)

So, if it's possible to detect broken middleware boxes without
spending too much time on it, that would really be nice.

Thomas
