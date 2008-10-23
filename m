From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] sctp: rfc conformance fixes
Date: Thu, 23 Oct 2008 16:47:32 +1100
Message-ID: <1224740852.7654.390.camel@pasglop>
References: <48FFBA06.50609@hp.com> <200810231143.22027.jk@ozlabs.org>
	 <200810231434.47989.jk@ozlabs.org>
	 <20081022.211148.98722383.davem@davemloft.net>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jk@ozlabs.org, vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	mbizon@freebox.fr, patchwork@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:47949 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752550AbYJWFrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2008 01:47:49 -0400
In-Reply-To: <20081022.211148.98722383.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-22 at 21:11 -0700, David Miller wrote:
> > OK, patchwork didn't like that the mail had no Content-Type header, so 
> > has no character set encoding defined. I've just checked-in change to 
> > assume a utf-8 encoding by default:
> > 
> > http://git.ozlabs.org/?p=patchwork;a=commitdiff;h=d45218b2e3894211e11313820bea9f59677c4bf2
> > 
> > Which should mean that future patches will be accepted.
> 
> Thanks a lot for fixing this Jeremy.  I bet some other patches got
> eaten by this too.
> 
> > (if you'd like me to manually re-inject that series of patches, just 
> > forward the mboxes over to me)
> 
> Not needed, I'll apply Vlad's patches since I have them in my inbox.

Since patchwork2 is new and might still occasionally have such a
problem, I though of a way to recover these...

If we keep an archive of the list, we can use patchwork hashing feature
to basically generate hashes for all patches in the archive over the
last N month, and then use the patchwork client interface to check if
they are all indeed referenced there. If not, we can then re-inject
them.

Typically a tool that could be used after we fix that sort of bug.
(There have been a couple of other similar ones related to weird
encodings in the past).

Cheers,
Ben.


