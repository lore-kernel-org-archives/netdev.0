From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: why usr/include/linux/if_frad.h is required
Date: Tue, 20 Jan 2009 20:53:27 +0100
Message-ID: <m3zlhlycso.fsf@intrepid.localdomain>
References: <1232463174.3088.15.camel@localhost.localdomain>
	<1232463242.3088.16.camel@localhost.localdomain>
	<200901201847.03030.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>,
	mike.mclagan@linux.org, Ingo Molnar <mingo@elte.hu>,
	Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org,
	davem@davemloft.net, LKML <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:54947 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755446AbZATTxd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 14:53:33 -0500
In-Reply-To: <200901201847.03030.arnd@arndb.de> (Arnd Bergmann's message of "Tue\, 20 Jan 2009 18\:47\:01 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> writes:

> The CONFIG_DLCI check in there is clearly in error, the definition in there
> is a user interface. The obvious solution is to drop the #if / #endif pair
> without a replacement.

I think so.
OTOH I'd be really surprised if anyone on the planet still used this
code/driver. IIRC and AFAICS it is (sdla.c coupled with dlci.c) the
first driver for the old Sangoma ISA sync serial cards (S502 - S508,
i.e. those based on Z80CPU doing HDLC and other things in firmware).


There was also a second(?) driver for those cards (official from
Sangoma), but:

commit 8db60bcf3021921e2d10d158641792d640e52fe8
Author: Adrian Bunk <bunk@stusta.de>
Date:   Tue Apr 11 17:28:33 2006 -0700

    [WAN]: Remove broken and unmaintained Sangoma drivers.
    
    The in-kernel Sangoma drivers are both not compiling and marked as BROKEN
    since at least kernel 2.6.0.
    
    Sangoma offers out-of-tree drivers, and David Mandelstam told me Sangoma
    does no longer maintain the in-kernel drivers and prefers to provide them
    as a separate installation package.
    
    This patch therefore removes these drivers.


They claim support for "All S-Series Legacy Cards" with out-of-tree
drivers available from www.sangoma.com.
-- 
Krzysztof Halasa
