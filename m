From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [PATCH] netlink: fix overrun in attribute iteration
Date: Fri, 12 Sep 2008 07:42:36 +0200
Message-ID: <19f34abd0809112242p27928541ydbfbb60ed84e34d2@mail.gmail.com>
References: <20080911205933.GA20032@localhost.localdomain>
	 <20080911165243.125a74cc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch,
	penberg@cs.helsinki.fi, mingo@elte.hu, viro@zeniv.linux.org.uk,
	linux-kernel@vger.kernel.org
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:60240 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbYILFmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 01:42:37 -0400
Received: by wa-out-1112.google.com with SMTP id j37so426200waf.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 22:42:36 -0700 (PDT)
In-Reply-To: <20080911165243.125a74cc.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2008 at 1:52 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 11 Sep 2008 22:59:33 +0200
> Vegard Nossum <vegard.nossum@gmail.com> wrote:
>
>>   #include <stdio.h>
>>
>>   main(void)
>>   {
>>           printf("%d\n", -1 >= sizeof(int));
>>   }
>>
>
> akpm:/home/akpm> gcc -W t.c
> t.c: In function 'main':
> t.c:5: warning: comparison between signed and unsigned
>
> Make of that what you will :)

It doesn't show up with -Wall and the kernel isn't compiled with -W
(aka. -Wextra) as far as I can see. Should it be turned on?


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
