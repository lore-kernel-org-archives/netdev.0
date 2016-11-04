From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: Coding Style: Reverse XMAS tree declarations ? (was Re: [PATCH
 net-next v6 02/10] dpaa_eth: add support for DPAA Ethernet)
Date: Fri, 4 Nov 2016 10:05:15 -0700
Message-ID: <5d4925c3-e6c1-8780-37bf-6d529f128cd9@infradead.org>
References: <1478117854-8952-1-git-send-email-madalin.bucur@nxp.com>
 <1478117854-8952-3-git-send-email-madalin.bucur@nxp.com>
 <20161103.155816.642712588084106823.davem@davemloft.net>
 <1478242438.1924.31.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org, oss@buserror.net,
        ppc@mindchasers.com, pebolle@tiscali.nl,
        joakim.tjernlund@transmode.se
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
        madalin.bucur@nxp.com, Andrew Morton <akpm@linux-foundation.org>,
        Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41322 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756934AbcKDRF0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 13:05:26 -0400
In-Reply-To: <1478242438.1924.31.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/16 23:53, Joe Perches wrote:
> On Thu, 2016-11-03 at 15:58 -0400, David Miller wrote:
>> From: Madalin Bucur <madalin.bucur@nxp.com>
>> Date: Wed, 2 Nov 2016 22:17:26 +0200
>>
>>> This introduces the Freescale Data Path Acceleration Architecture
>>> +static inline size_t bpool_buffer_raw_size(u8 index, u8 cnt)
>>> +{
>>> +     u8 i;
>>> +     size_t res = DPAA_BP_RAW_SIZE / 2;
>>
>> Always order local variable declarations from longest to shortest line,
>> also know as Reverse Christmas Tree Format.
> 
> I think this declaration sorting order is misguided but
> here's a possible change to checkpatch adding a test for it
> that does this test just for net/ and drivers/net/

I agree with the misguided part.
That's not actually in CodingStyle AFAICT. Where did this come from?


thanks.
-- 
~Randy
