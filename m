From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next] net: remove unnecessary return's
Date: Fri, 14 Feb 2014 10:58:00 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1402141055270.2118@hadrien>
References: <alpine.DEB.2.02.1402132252290.1967@localhost6.localdomain6> <20140213220021.GA1174@redhat.com> <alpine.DEB.2.02.1402132327480.1967@localhost6.localdomain6> <20140213.181416.1185115361356253646.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davej@redhat.com, joe@perches.com, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:7424 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751277AbaBNJ6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 04:58:06 -0500
In-Reply-To: <20140213.181416.1185115361356253646.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Feb 2014, David Miller wrote:

> From: Julia Lawall <julia.lawall@lip6.fr>
> Date: Thu, 13 Feb 2014 23:28:27 +0100 (CET)
>
> > On Thu, 13 Feb 2014, Dave Jones wrote:
> >
> >> On Thu, Feb 13, 2014 at 10:55:23PM +0100, Julia Lawall wrote:
> >>
> >>  > The patch below converts label: return; } to label: ; }.  I have only
> >>  > scanned through the patches, not patched the code and looked at the
> >>  > results, so I am not sure that it is completely correct.  On the other
> >>  > hand, I'm also not sure that label: ; } is better than label: return; },
> >>  > either.  If people think it is, then I can cheack the results in more
> >>  > detail.
> >>
> >> Why not delete the label, and just replace the goto with a return if
> >> the label is at the end of the function ?
> >
> > Here is an example.  Perhaps the uniformity of the if ... goto pattern is
> > valuable, though?
>
> I think it is valuable, it's so much easier to audit the return paths
> via a process of elimination with that kind of layout.  A return in
> the middle of that looks out of place at best.

Actually, I had a student who made a tool that went the other way around,
and introduced goto labels for sharable error handling code.  We didn't
get around to using it to send patches, though.  In that tool, we didn't
create labels just for returns, with the thought that in that case there
was no point to introduce a goto if there was nothing to share.

julia
