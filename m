From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] bonding: fix broken multicast with round-robin
 mode
Date: Wed, 31 Mar 2010 14:00:55 -0700 (PDT)
Message-ID: <20100331.140055.246389406.davem@davemloft.net>
References: <1270026517.2103.9.camel@edumazet-laptop>
	<m2x7b667921003310749v5c8b6e62g7339eff24a51e6d8@mail.gmail.com>
	<1270048448.2103.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org, lhh@redhat.com,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58753
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753207Ab0CaVAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 17:00:53 -0400
In-Reply-To: <1270048448.2103.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 31 Mar 2010 17:14:08 +0200

> ARCH=x86_64 CROSS_COMPILE=x86_64-unknown-linux- make vmlinux
> 
> so, it was a cross compiler :
> 
> /data/x86-64/bin/x86_64-unknown-linux-gcc-4.1.2 -v
> Using built-in specs.
> Target: x86_64-unknown-linux
> Configured with: ../gcc-4.1.2/configure --prefix=/data/x86-64
> --target=x86_64-unknown-linux --enable-languages=c --disable-shared
> --disable-multilib --disable-threads --disable-libssp --without-headers
> --disable-libmudflap
> Thread model: single
> gcc version 4.1.2

Funny how going back in time gives us better diagnostic messages from
the compiler :-)

FWIW I also didn't get the warning, and that was with gcc-4.5 built
from the gcc trunk just the other day.

I suspect this is to do with a change to what warnings get enabled by
default with the -W options we put in the cflags rather than gcc
losing the ability to detect this case.
