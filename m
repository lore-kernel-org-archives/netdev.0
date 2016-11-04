From: David Miller <davem@davemloft.net>
Subject: Re: Coding Style: Reverse XMAS tree declarations ?
Date: Fri, 04 Nov 2016 11:07:59 -0400 (EDT)
Message-ID: <20161104.110759.1093635654135143910.davem@davemloft.net>
References: <20161103.155816.642712588084106823.davem@davemloft.net>
        <1478242438.1924.31.camel@perches.com>
        <581C6A7D.8030704@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, madalin.bucur@nxp.com, akpm@linux-foundation.org,
        corbet@lwn.net, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
        oss@buserror.net, ppc@mindchasers.com, pebolle@tiscali.nl,
        joakim.tjernlund@transmode.se
To: lsanfil@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <581C6A7D.8030704@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lino Sanfilippo <lsanfil@marvell.com>
Date: Fri, 4 Nov 2016 12:01:17 +0100

> Hi,
> 
> On 04.11.2016 07:53, Joe Perches wrote:
>>
>> CHECK:REVERSE_XMAS_TREE: Prefer ordering declarations longest to
>> shortest
>> #446: FILE: drivers/net/ethernet/ethoc.c:446:
>> +			int size = bd.stat >> 16;
>> +			struct sk_buff *skb;
>>
> 
> should not this case be valid? Optically the longer line is already
> before the shorter.
> I think that the whole point in using this reverse xmas tree ordering
> is to have
> the code optically tidied up and not to enforce ordering between
> variable name lengths.

That's correct.
