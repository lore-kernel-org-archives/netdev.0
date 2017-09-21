From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next 09/14] gtp: Allow configuring GTP interface as
 standalone
Date: Thu, 21 Sep 2017 08:13:13 +0800
Message-ID: <20170921001313.n2uo56oxmphcvd5g@nataraja>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919003904.5124-10-tom@quantonium.net>
 <a6d1dad0-e922-2913-d4c8-592d403ee1cb@tpip.net>
 <CALx6S3771X4QUm2mJG=aJJ0f4Tm98NpGA7060vF1P8iuCPgicQ@mail.gmail.com>
 <56e339a8-fa2d-6f8d-a89c-c0f3f242763a@tpip.net>
 <CAPDqMeq1tLi=NkLyqma2OEHQi-fYEYeTU-8th9WKoZaeWiM0Rw@mail.gmail.com>
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
Received: from ganesha.gnumonks.org ([213.95.27.120]:32772 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751663AbdIUANa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 20:13:30 -0400
Content-Disposition: inline
In-Reply-To: <CAPDqMeq1tLi=NkLyqma2OEHQi-fYEYeTU-8th9WKoZaeWiM0Rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Wed, Sep 20, 2017 at 09:24:07AM -0700, Tom Herbert wrote:
> On Wed, Sep 20, 2017 at 9:07 AM, Andreas Schultz <aschultz@tpip.net> wrote:
> > GTP isn't special, I just don't like to have testing only features in there
> > when the same goal can be reached without having to add extra stuff. Adding
> > code that is not going to be useful in real production setups (or in this
> > case would even break production setups when enabled accidentally) makes the
> > implementation more complex than it needs to be.
> 
> Well, you could make the same argument that allowing GTP to configured
> as standalone interface is a problem since GTP is only allowed to be
> with used with GTP-C. But, then we have something in the kernel that
> the community is expected to support, but requires jumping through a
> whole bunch of hoops just to run a simple netperf. 

"A whole bunch of hoops" without your new interface would consist of
running a single command-line program that is supplied with libgtpnl.
This is not a complete 3GPP network, but a simple libmnl-based helper
library with no other depenencies.

I'm not neccessarily against introducing features like the 'standalone
interface configuration'.  However, we must make sure that any
significant new feature contributions like IPv6 are tested in a
"realistic setup" and not just using those 'interfaces added for easy
development'.  Also, I would argue those 'interfaces added for easy
deveopment/benchmarking' should probably be clearly marked as such to
avoid raising the impression that this is what leads to a
standard-conforming / production-type setup.

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
