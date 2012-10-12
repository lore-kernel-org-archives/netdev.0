From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: alignment faults in 3.6
Date: Fri, 12 Oct 2012 14:08:12 +0200
Message-ID: <1350043692.21172.11815.camel@edumazet-glaptop>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com>
	 <yw1xtxu1nfsn.fsf@unicorn.mansr.com> <201210120811.43290.arnd@arndb.de>
	 <20121012090321.GA21164@n2100.arm.linux.org.uk>
	 <yw1xhaq0nefg.fsf@unicorn.mansr.com>
	 <20121012110750.GE21164@n2100.arm.linux.org.uk>
	 <yw1x8vbcndlb.fsf@unicorn.mansr.com>
	 <20121012114443.GG21164@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	David Laight <David.Laight@aculab.com>, netdev@vger.kernel.org,
	Jon Masters <jonathan@jonmasters.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60201 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756117Ab2JLMIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 08:08:15 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1514053bkc.19
        for <netdev@vger.kernel.org>; Fri, 12 Oct 2012 05:08:14 -0700 (PDT)
In-Reply-To: <20121012114443.GG21164@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-12 at 12:44 +0100, Russell King - ARM Linux wrote:

> - You were demanding that the ipv4 header structure should be packed.
>   I said that wasn't going to happen because the networking people
>   wouldn't allow it, and it seems that's been proven correct.
> - You were demanding that the ipv4 code used the unaligned accessors.
>   I said that networking people wouldn't allow it either, and that's
>   also been proven correct.
> 
> Both these points have been proven correct because Eric has said that the
> core networking code is _not_ going to be changed to suit this.
> 
> What Eric _has_ said is that networking people consider packets supplied
> to the networking layer where the IPv4 header is not aligned on architectures
> where misaligned accesses are a problem to be a bug in the network driver,
> not the network code, and proposed a solution.
> 
> That's entirely different from all your claims that the core networking
> code needs fixing to avoid these misaligned accesses.

It seems we agree then, but your words were a bit misleading (at least
for me)

So yes, we built network stack with the prereq that IP headers are
aligned, but unfortunately many developers use x86 which doesnt care, so
its possible some bugs are added.

But its not by intent, only by accident.

Thanks
