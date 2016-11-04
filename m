From: David VomLehn <vomlehn@texas.net>
Subject: Re: Coding Style: Reverse XMAS tree declarations ? (was Re: [PATCH
 net-next v6 02/10] dpaa_eth: add support for DPAA Ethernet)
Date: Fri, 4 Nov 2016 13:48:24 -0600
Message-ID: <20161104194824.GA5533@gracie>
References: <1478117854-8952-1-git-send-email-madalin.bucur@nxp.com>
 <1478117854-8952-3-git-send-email-madalin.bucur@nxp.com>
 <20161103.155816.642712588084106823.davem@davemloft.net>
 <1478242438.1924.31.camel@perches.com>
 <5d4925c3-e6c1-8780-37bf-6d529f128cd9@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
        madalin.bucur@nxp.com, Andrew Morton <akpm@linux-foundation.org>,
        Jonathan Corbet <corbet@lwn.net>, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
        oss@buserror.net, ppc@mindchasers.com, pebolle@tiscali.nl,
        joakim.tjernlund@transmode.se
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda2.aus1.datafoundry.com ([209.99.124.133]:35215 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752794AbcKDTsa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 15:48:30 -0400
Content-Disposition: inline
In-Reply-To: <5d4925c3-e6c1-8780-37bf-6d529f128cd9@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 04, 2016 at 10:05:15AM -0700, Randy Dunlap wrote:
> On 11/03/16 23:53, Joe Perches wrote:
> > On Thu, 2016-11-03 at 15:58 -0400, David Miller wrote:
> >> From: Madalin Bucur <madalin.bucur@nxp.com>
> >> Date: Wed, 2 Nov 2016 22:17:26 +0200
> >>
> >>> This introduces the Freescale Data Path Acceleration Architecture
> >>> +static inline size_t bpool_buffer_raw_size(u8 index, u8 cnt)
> >>> +{
> >>> +     u8 i;
> >>> +     size_t res = DPAA_BP_RAW_SIZE / 2;
> >>
> >> Always order local variable declarations from longest to shortest line,
> >> also know as Reverse Christmas Tree Format.
> > 
> > I think this declaration sorting order is misguided but
> > here's a possible change to checkpatch adding a test for it
> > that does this test just for net/ and drivers/net/
> 
> I agree with the misguided part.
> That's not actually in CodingStyle AFAICT. Where did this come from?
> 
> 
> thanks.
> -- 
> ~Randy

This puzzles me. The CodingStyle gives some pretty reasonable rationales
for coding style over above the "it's easier to read if it all looks the
same". I can see rationales for other approaches (and I am not proposing
any of these):

alphabetic order        Easier to search for declarations
complex to simple       As in, structs and unions, pointers to simple
                        data (int, char), simple data. It seems like I
                        can deduce the simple types from usage, but more
                        complex I need to know things like the
                        particular structure.
group by usage          Mirror the ontological locality in the code

Do we have a basis for thinking this is easier or more consistent than
any other approach?
-- 
David VL
