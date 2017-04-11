From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 01/10] ftgmac100: Upgrade to NETIF_F_HW_CSUM
Date: Tue, 11 Apr 2017 23:50:10 +1000
Message-ID: <1491918610.7236.12.camel@kernel.crashing.org>
References: <20170411010436.23290-1-benh@kernel.crashing.org>
         <20170411010436.23290-2-benh@kernel.crashing.org>
         <7d0f6000-3be5-ed70-49d3-3a3916dd79ff@cogentembedded.com>
         <1491909225.4166.248.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54939 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752801AbdDKNuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 09:50:16 -0400
In-Reply-To: <1491909225.4166.248.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-11 at 21:13 +1000, Benjamin Herrenschmidt wrote:
> On Tue, 2017-04-11 at 13:57 +0300, Sergei Shtylyov wrote:
> >     Need {} here as well since the 1st branch has it -- see 
> > Documentation/process/coding-style.rst (the end of the section 3).
> 
> Adding {} in that specific statements just makes things more
> cluttered and less readable.
> 
> I can find a ton of examples of 
> 
> 	if (...) {
> 		multi lines
> 		...
> 	} else if (...)
> 		single_line()
> 
> In existing kernel code.
> 
> I'll fix it in a next spin if Dave wants it that way but otherwise
> I'm keen to leave it as it is.

I actually took the time to read the coding-style.txt statement,
and I would argue that it is about

	if (...) {
		...
	} else {
		...
	}

Which is a different can of worms. I tend to agree that the else by
itself followed by a single tabulated statement is a bit "odd" and
I tend to use braces in that case as well.

However the "} else if (...)" case is subtly different and from a code
clarity point of view I prefer what I wrote.

This isn't an accident, I specifically wrote that statement that way
because I preferred how the code looked like that way.

This tend to be my problem with coding style rules (and people who
comment on patches solely on coding style issues, especially so
marginal ones ;-) ... this needs to be applied along with a bit of
common sense and taste.

Those rules should be "general guidelines" not absolute laws. A
specific piece of code might benefit from violating some of them
occasionally for all sort of reasons provided the end result is both
clear and more concise for example.

Anyway, way too much internet bandwidth wasted today on that subject.

Dave, just let me know how you want it to look like :-)

Cheers,
Ben.
  
