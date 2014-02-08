From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Re: [PATCH] tcp: disable auto corking by default
Date: Sat, 8 Feb 2014 17:55:39 +0100
Message-ID: <20140208165539.GA22359@glanzmann.de>
References: <20140206153640.GB4103@glanzmann.de>
 <1391727771.14985.41.camel@haakon3.risingtidesystems.com>
 <20140207051500.GB10916@glanzmann.de>
 <20140207075536.GB17815@glanzmann.de>
 <1391801597.1155.28.camel@haakon3.risingtidesystems.com>
 <20140207205142.GA8609@glanzmann.de>
 <20140208091828.GA16336@glanzmann.de>
 <20140208091944.GB16336@glanzmann.de>
 <1391871850.10160.103.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1391871850.10160.103.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Eric,

> > Disable auto corking by default

> We should let auto corking on during 3.14 development cycle so that we
> can fix the bugs, and thing of some optimizations.

I agree that leaving it enabled helps to find bugs, however I'm not
happy with the round trip time degradation.

> auto cork gives a strong incentive to applications to use
> TCP_CORK/MSG_MORE to avoid overhead of sending multiple small
> segments.

I agree. But if it breaks the application many people won't be happy,
for example I spend already 5 hours to track it down.

> In the normal case, the extra delay is something like 10 us, so if an
> application is really hit by this delay, its a strong sign it could be
> improved, especially if auto corking is off.

Yes, but 230 micro seconds for others. :-(

> Lets wait the end of 3.14 dev cycle before considering this patch.

I agree.

Btw. I mixed up the pcaps for autocork on and off, so I moved the files
that they know show what they should show.

Cheers,
        Thomas
