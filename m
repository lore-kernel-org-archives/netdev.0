From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: why usr/include/linux/if_frad.h is required
Date: Wed, 21 Jan 2009 17:38:38 +1100
Message-ID: <20090121173838.3390e5c9@s6510>
References: <m3bpu1xyb9.fsf@intrepid.localdomain>
	<3f9a31f40901202050u4b85fef2p8b9848b865c4fda0@mail.gmail.com>
	<20090121053310.GA26395@uranus.ravnborg.org>
	<20090120.221504.264090722.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sam@ravnborg.org, jaswinderlinux@gmail.com, khc@pm.waw.pl,
	jaswinder@kernel.org, arnd@arndb.de, mingo@elte.hu,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36141 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751196AbZAUGjR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2009 01:39:17 -0500
In-Reply-To: <20090120.221504.264090722.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Jan 2009 22:15:04 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Sam Ravnborg <sam@ravnborg.org>
> Date: Wed, 21 Jan 2009 06:33:10 +0100
> 
> > On Wed, Jan 21, 2009 at 10:20:17AM +0530, Jaswinder Singh Rajput wrote:
> > > On Wed, Jan 21, 2009 at 6:36 AM, Krzysztof Halasa <khc@pm.waw.pl> wrote:
> > > > Jaswinder Singh Rajput <jaswinder@kernel.org> writes:
> > > >
> > > >> usr/include/linux/if_frad.h is covered with CONFIG_DLCI from many years
> > > >> and no body is complaining about it so it means no body is using it.
> > > >>
> > > >> So should we need to drop #if / #endif pair or the whole file from
> > > >> userspace.
> > > >
> > > > I think the file. "Empty file exported to userspace", long unused. We
> > > > can also have it back there, and it being not exported is an indicator
> > > > that it's not used. I guess the #ifdef __KERNEL__ can be removed, too.
> > > 
> > > I will definately define #ifdef __KERNEL__ but I am also curious after
> > > defining it there is no point of making empty
> > > usr/include/linux/if_frad.h
> > 
> > Googling a bit did not turn up _any_ non-kernel hits that has relevance.
> > So based on the information given in this thread I strongly
> > suggest to drop the export of this header.
> 
> Sure, but on the other hand this makes all of the userland APIs
> essentially inaccessible and undefined.
> 
> I bet Sangoma's internal tools reference this stuff.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

There are no references if_frad.h in the version of Sangoma (out of tree) code
that we use in Vyatta. 
