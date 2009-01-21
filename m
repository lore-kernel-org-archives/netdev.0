From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: why usr/include/linux/if_frad.h is required
Date: Wed, 21 Jan 2009 06:33:10 +0100
Message-ID: <20090121053310.GA26395@uranus.ravnborg.org>
References: <1232463174.3088.15.camel@localhost.localdomain> <1232463242.3088.16.camel@localhost.localdomain> <200901201847.03030.arnd@arndb.de> <m3zlhlycso.fsf@intrepid.localdomain> <1232495335.3123.13.camel@localhost.localdomain> <m3bpu1xyb9.fsf@intrepid.localdomain> <3f9a31f40901202050u4b85fef2p8b9848b865c4fda0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Jaswinder Singh Rajput <jaswinder@kernel.org>,
	Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org, davem@davemloft.net,
	LKML <linux-kernel@vger.kernel.org>
To: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepa.post.tele.dk ([195.41.46.235]:32796 "EHLO
	pfepa.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbZAUFb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 00:31:26 -0500
Content-Disposition: inline
In-Reply-To: <3f9a31f40901202050u4b85fef2p8b9848b865c4fda0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2009 at 10:20:17AM +0530, Jaswinder Singh Rajput wrote:
> On Wed, Jan 21, 2009 at 6:36 AM, Krzysztof Halasa <khc@pm.waw.pl> wrote:
> > Jaswinder Singh Rajput <jaswinder@kernel.org> writes:
> >
> >> usr/include/linux/if_frad.h is covered with CONFIG_DLCI from many years
> >> and no body is complaining about it so it means no body is using it.
> >>
> >> So should we need to drop #if / #endif pair or the whole file from
> >> userspace.
> >
> > I think the file. "Empty file exported to userspace", long unused. We
> > can also have it back there, and it being not exported is an indicator
> > that it's not used. I guess the #ifdef __KERNEL__ can be removed, too.
> 
> I will definately define #ifdef __KERNEL__ but I am also curious after
> defining it there is no point of making empty
> usr/include/linux/if_frad.h

Googling a bit did not turn up _any_ non-kernel hits that has relevance.
So based on the information given in this thread I strongly
suggest to drop the export of this header.

	Sam
