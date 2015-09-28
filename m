From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 0/4] ila: Use NF_INET_PRE_ROUTING nfhook
Date: Tue, 29 Sep 2015 01:00:10 +0200
Message-ID: <20150928230010.GB19923@breakpoint.cc>
References: <1443112224-574543-1-git-send-email-tom@herbertland.com>
 <20150926.231554.1860934088223264189.davem@davemloft.net>
 <20150927081055.GA17055@breakpoint.cc>
 <CALx6S35gFbcFjCWEQsDY_DzBOrr0i7+3fdBWiF4rLmcz9HJRBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:38685 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752984AbbI1XAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 19:00:15 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S35gFbcFjCWEQsDY_DzBOrr0i7+3fdBWiF4rLmcz9HJRBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
> RFC6296 doesn't work because it allows an invalid checksum to be sent
> on wire relative to the addresses used on the wire. That means we
> would lose CHECKSUM_UNNECESSARY for ILA which is way too big of a
> performance hit.

Not following.  I did not say you should use NPT instead of ILA.

[..]
> In any case, I did at one point create some netfilter targets for ILA
> to do the translation correctly updating the checksum. While this
> provided the required functionality, I couldn't get sufficient
> performance. A specialized fixed length lookup table gets most of the
> performance needed for ILA.

I'm not following at all.

Could you explain why you can't just 'relocate' your proposed
implementation to netfilter/ipv6?

F.e. I see no reason why you could not use a lookup table in a netfilter
target (or nft expression, for that matter) ... ?

Thanks,
Florian
