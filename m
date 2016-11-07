From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: Coding Style: Reverse XMAS tree declarations ? (was Re: [PATCH net-next v6 02/10] dpaa_eth: add support for DPAA Ethernet)
Date: Mon, 07 Nov 2016 19:05:40 +1100
Message-ID: <877f8fn297.fsf@concordia.ellerman.id.au>
References: <1478117854-8952-1-git-send-email-madalin.bucur@nxp.com> <1478117854-8952-3-git-send-email-madalin.bucur@nxp.com> <20161103.155816.642712588084106823.davem@davemloft.net> <1478242438.1924.31.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: pebolle@tiscali.nl, joakim.tjernlund@transmode.se,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ppc@mindchasers.com, oss@buserror.net,
        linuxppc-dev@lists.ozlabs.org
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
        madalin.bucur@nxp.com, Andrew Morton <akpm@linux-foundation.org>,
        Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:41971 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751203AbcKGIFn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Nov 2016 03:05:43 -0500
In-Reply-To: <1478242438.1924.31.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> writes:
> On Thu, 2016-11-03 at 15:58 -0400, David Miller wrote:
>> From: Madalin Bucur <madalin.bucur@nxp.com>
>> Date: Wed, 2 Nov 2016 22:17:26 +0200
>> 
>> > This introduces the Freescale Data Path Acceleration Architecture
>> > +static inline size_t bpool_buffer_raw_size(u8 index, u8 cnt)
>> > +{
>> > +     u8 i;
>> > +     size_t res = DPAA_BP_RAW_SIZE / 2;
>> 
>> Always order local variable declarations from longest to shortest line,
>> also know as Reverse Christmas Tree Format.
>
> I think this declaration sorting order is misguided but
> here's a possible change to checkpatch adding a test for it
> that does this test just for net/ and drivers/net/

And arch/powerpc too please.

cheers
