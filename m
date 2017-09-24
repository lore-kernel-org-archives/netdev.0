From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH net-next 09/14] gtp: Allow configuring GTP interface as
 standalone
Date: Mon, 25 Sep 2017 00:25:43 +0800
Message-ID: <20170924162543.d7syskutxzgvbw23@nataraja>
References: <a6d1dad0-e922-2913-d4c8-592d403ee1cb@tpip.net>
 <CALx6S3771X4QUm2mJG=aJJ0f4Tm98NpGA7060vF1P8iuCPgicQ@mail.gmail.com>
 <56e339a8-fa2d-6f8d-a89c-c0f3f242763a@tpip.net>
 <CAPDqMeq1tLi=NkLyqma2OEHQi-fYEYeTU-8th9WKoZaeWiM0Rw@mail.gmail.com>
 <20170921001313.n2uo56oxmphcvd5g@nataraja>
 <CAPDqMeox74aEdV5_cr7HJ=kh0-etLdFE-u5=g8OqRzmS8OjOuQ@mail.gmail.com>
 <20170921151253.4udm54dcq7x3ed4q@nataraja>
 <CAPDqMeq69rjzPh8jo-G9gKT26h-br4OrE0yxTJGk97qRgX0K2A@mail.gmail.com>
 <20170924021626.b37zlwsomlibtnfs@nataraja>
 <CAPDqMer0R+XoTzYpQoo7rUY3uVcsa6ffk1FHjkG=3xcuhnDgXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Schultz <aschultz@tpip.net>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Rohit Seth <rohit@quantonium.net>
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:36851 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752416AbdIXQ0K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 12:26:10 -0400
Content-Disposition: inline
In-Reply-To: <CAPDqMer0R+XoTzYpQoo7rUY3uVcsa6ffk1FHjkG=3xcuhnDgXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Sun, Sep 24, 2017 at 08:55:49AM -0700, Tom Herbert wrote:
> Do you believe that these patches are not at all on the right track,
> that they can't be built upon to get to a standards-compliant
> implementation, and that we are going to have to throw all of this and
> start from scratch to provide IPv6 support?

I believe I have pointed out where the problem areas are, several times
by now.  I see no reason why things would have to be started from
scratch.  However, the issues pointed out in the IPv6 support patch[es]
have to be resolved *before* any merge to mainline.

I don't mind merging "incomplete" code that doesn't cover all parts of a
spec but provides basic interoperability.  I also am not arguing that
code must be bug-free at the time it is merged (which is impossible
anyway).  But I am arguing that we cannot merge something that is
a wrong implementation as per the spec, and hence it must be brought
in-line with the spec before it can be merged.

> > There's no use in merging an IPv6 support patch if already by code
> > review it can be shown that it's impossible to create a spec-compliant
> > implementation using that patch.  To me, that would be "merging IPv6
> > support so we can check off a box on a management form or marketing
> > sheet", but not for any practical value.
> 
> To be clear, these patches are not done because to be a bullet point
> on a marketing sheet. 

Great.

> IPv6 is becoming _the_ Internet protocol.

I'm all aware of that, and I've been a very early adopter, since the
1990ies with 6bone.

My argument is not against IPv6 support.  My argument is against merging
something that introdues IPv6 in a way that's not in-line with the GTP
protocol specifications, as such a way is of no use to anyone (except
marketing sheets).

> We should be far past the days of vendors only providing IPv4 in the
> kernel support because "that's what our customers use" and they'll get
> to IPv6 support at their leisure. 

I'm not sure where a "vendor" is involved with the GTP patches so far.  I
think we have to draw a distinction between what you expect from
professional, corporate "vendors" with a commercial interest in mind
(such as supporting their hardware) and what you can expect from people
doing things in their spare time, out of enthusiasm to finally bring
some Free Software into the closed world of telecommunications.

The Telecom world should have implemented something like a GTP kernel
module a decade to 15 years ago.  They could have saved significant
investments in proprietary hardware by running open source GGSNs with an
accelerated user plane in the kernel.  Nobody seemed to have an interest
in that, until today - as you can see from Pablo and me working on this
in our spare time, whenever we have a couple of spare cycles next to
many other projects.  You can see from the osmo-gtp-kernel commit log it
took years of being a ultra-low-priority on-and-off project  to ever get
to a point where we thought it was worth submitting it mainline.
Andreas deserves the praise for finally pushing it ahead.

I'm looking forward to reviewing the next version of the patch series.
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
