From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection opening
Date: Wed, 8 Oct 2008 19:07:39 +0200
Message-ID: <20081008170739.GA546@1wt.eu>
References: <20081008081109.GA25342@1wt.eu> <20081008.094212.130684373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4671 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752788AbYJHRHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 13:07:44 -0400
Content-Disposition: inline
In-Reply-To: <20081008.094212.130684373.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 09:42:12AM -0700, David Miller wrote:
> 
> I'm not really interested in applying this.

OK.

> You can make the same argument for just about any queer corner case
> aspect of TCP.

Not exactly since there are very few corner cases not conditionned by
guessing a 32-bit sequence number, and this one certainly is.

> The world hasn't ended even though this patch hasn't applied since
> 2005

Oh don't take me wrong. I'm pretty much convinced this is not critical at
all. It's just that it's a tempting attack vector for an easy DoS proof
of concept relying on a feature not even usable today.

> and that's a good argument to not apply "yet another random knob"
> to the kernel.

OK for the random knob. If you feel comfortable with a patch to simply remove
the feature, I can send you such a patch too. BTW, the strange netstat output
I got also shows that the code paths involved to support this feature are not
much exercised, which would be another argument to disable it.

Anyway, I'm not trying to put any pressure. I can continue to live with the
ifdef patch in my trees. I just wanted to get your opinion on this one since
the discussion I initiated about it in 2005 brought to nowhere.

Regards,
Willy

