From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 9816] New: cannot replace route
Date: Sat, 26 Jan 2008 16:19:34 +0100
Message-ID: <20080126151934.GA2969@ami.dom.local>
References: <bug-9816-10286@http.bugzilla.kernel.org/> <20080125142603.a73fd7a2.akpm@linux-foundation.org> <479A6CBD.4010908@gmail.com> <20080125192026.e667f396.akpm@linux-foundation.org> <b25c3fa70801252116h2b9f12c9j65a8a75dbd0d5662@mail.gmail.com> <20080126114036.GA2624@ami.dom.local> <20080126141010.GC2624@ami.dom.local> <jeve5gd5mz.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joonwoo Park <joonwpark81@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Andreas Schwab <schwab@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:50483 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbYAZPPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2008 10:15:05 -0500
Received: by ug-out-1314.google.com with SMTP id z38so676185ugc.16
        for <netdev@vger.kernel.org>; Sat, 26 Jan 2008 07:15:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <jeve5gd5mz.fsf@sykes.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 26, 2008 at 03:27:00PM +0100, Andreas Schwab wrote:
> Jarek Poplawski <jarkao2@gmail.com> writes:
> 
> > And, after re-reading this bugzilla report, I'm pretty sure the thing
> > should be done with 'ip route change' (but I didn't check if 2.6.24
> > knows about this...).
> 
> $ man ip
> [...]
>    ip route add - add new route
>    ip route change - change route
>    ip route replace - change or add new one
> [...]
> 
> According to this "replace" should be a superset of "change".

According to this "replace" should be ...ambiguous. I could read this
"my/proper(?) way":

    ip route replace - change with new one or add new one

And ...man could be wrong too after all! (...but not me!)

> Also, please check out comment#3, it also fails for replacing a route
> with something different (it's a route to an ipsec tunnel).

It all depends on which routes should be considered different (and it
should be specified somewhere BTW...).

But, I should've added my all reasoning was more about logic, and since
in real life change and replace are often equivalent, and iproute is
famous from using such equivalents in many places, your claim WRT this
man page could be completely right!

There should be only considered, if realization of this doesn't imply
bugs in some other places, like the one which fix caused this
"regression".

Regards,
Jarek P.
