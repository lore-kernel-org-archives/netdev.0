From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: why usr/include/linux/if_frad.h is required
Date: Wed, 21 Jan 2009 02:06:18 +0100
Message-ID: <m3bpu1xyb9.fsf@intrepid.localdomain>
References: <1232463174.3088.15.camel@localhost.localdomain>
	<1232463242.3088.16.camel@localhost.localdomain>
	<200901201847.03030.arnd@arndb.de>
	<m3zlhlycso.fsf@intrepid.localdomain>
	<1232495335.3123.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@elte.hu>,
	Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org,
	davem@davemloft.net, LKML <linux-kernel@vger.kernel.org>
To: Jaswinder Singh Rajput <jaswinder@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763400AbZAUBGc@vger.kernel.org>
In-Reply-To: <1232495335.3123.13.camel@localhost.localdomain> (Jaswinder Singh Rajput's message of "Wed\, 21 Jan 2009 05\:18\:55 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jaswinder Singh Rajput <jaswinder@kernel.org> writes:

> usr/include/linux/if_frad.h is covered with CONFIG_DLCI from many years
> and no body is complaining about it so it means no body is using it.
>
> So should we need to drop #if / #endif pair or the whole file from
> userspace.

I think the file. "Empty file exported to userspace", long unused. We
can also have it back there, and it being not exported is an indicator
that it's not used. I guess the #ifdef __KERNEL__ can be removed, too.
-- 
Krzysztof Halasa
