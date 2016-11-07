From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Coding Style: Reverse XMAS tree declarations ?
Date: Mon, 7 Nov 2016 11:00:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB021646E@AcuExch.aculab.com>
References: <20161103.155816.642712588084106823.davem@davemloft.net>
 <1478242438.1924.31.camel@perches.com> <581C6A7D.8030704@marvell.com>
 <20161104.110759.1093635654135143910.davem@davemloft.net>
 <1478281455.1924.41.camel@perches.com>
 <31ace8dd-1e42-2762-6367-028068d4d816@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "madalin.bucur@nxp.com" <madalin.bucur@nxp.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "corbet@lwn.net" <corbet@lwn.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "oss@buserror.net" <oss@buserror.net>,
        "ppc@mindchasers.com" <ppc@mindchasers.com>,
        "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
        "joakim.tjernlund@transmode.se" <joakim.tjernlund@transmode.se>,
        Randy Dunlap <rdunlap@infradead.org>
To: 'Lino Sanfilippo' <LinoSanfilippo@gmx.de>,
        Joe Perches <joe@perches.com>,
        David Miller <davem@davemloft.net>,
        "lsanfil@marvell.com" <lsanfil@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <31ace8dd-1e42-2762-6367-028068d4d816@gmx.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lino Sanfilippo
> Sent: 04 November 2016 20:07
...
> In this case it is IMHO rather the declaration + initialization that makes
> "bar" hard to find at one glance, not the use of RXT. You could do something like
> 
>  	[longish list of reverse xmas tree identifiers...]
>  	struct foobarbaz *qux;
>  	struct foo *bar;
> 
>  	bar = longish_function(args, ...);
> 
> to increase readability.
> 
> Personally I find it more readable to always use a separate line for initializations
> by means of functions (regardless of whether the RXT scheme is used or not).

I find it best to only use initialisers for 'variables' that are (mostly) constant.
If something need to be set to NULL in case a search fails, set it to NULL
just before the loop.
Don't put initialisation on the declaration 'because you can'.

Difficulty in spotting the type of a variable is why (IMHO) you should
but all declarations at the top of a function
(except, maybe, temporaries needed for a few lines).

	David
