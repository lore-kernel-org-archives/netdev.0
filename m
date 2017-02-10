From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Thu, 09 Feb 2017 22:33:48 -0500 (EST)
Message-ID: <20170209.223348.2143869696524078186.davem@davemloft.net>
References: <CALx6S368wyPdLkyvAhFG3BXJFJifFSJSK+x__2sQr1rGeP8aRw@mail.gmail.com>
        <20170209.204229.1662524081519832785.davem@davemloft.net>
        <CALx6S37_GOP4a0x2aVbde1ynZRxDXx3A+YfY6sMMEZQEKN_1+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57738 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750972AbdBJDeI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 22:34:08 -0500
In-Reply-To: <CALx6S37_GOP4a0x2aVbde1ynZRxDXx3A+YfY6sMMEZQEKN_1+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 9 Feb 2017 18:29:54 -0800

> So we have thousands or LOC coming into drivers every day anyway with
> all those properties anyway, so this "restricted" environment solves
> at best 1% of the problem.

What you must understand is that no matter what someone outside of
upstream writes into an eBPF program, it's safe, and we can absolutely
prove this with the verifier and the invariants of the execution
environment.

Real kernel modules have no such restricted scope.

This is the fundamental issue.

Even if I agreed with you, it's tremendously frustrating that we
haven't even touched the surface of what eBPF XDP can do, and yet
you're openning the floodgates to something we cannot even prove
we need or is required yet.

XDP via eBPF in it's current form needs more work and it needs to be
fully fleshed out and more user friendly.  That's where the effort
and engineering resources belong right now.

After that you can say "Ok, now we have that just about feature
complete, here is the thing that's not possible and that's why we need
X" You think you can answer that right now, and I know that it's not
true.  There is so much that eBPF XDP can do with the right mix of
care and helper functions.  I actually really see no fundamental limit
to what it is capable of doing with the proper design.
