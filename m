From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: AF_BUS socket address family
Date: Fri, 29 Jun 2012 20:33:41 +0100
Message-ID: <1340998421.3066.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
	 <4FEDF107.8030700@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vincent Sanders <vincent.sanders@collabora.co.uk>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FEDF107.8030700@genband.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-06-29 at 12:16 -0600, Chris Friesen wrote:
> On 06/29/2012 10:45 AM, Vincent Sanders wrote:
> > This series adds the bus address family (AF_BUS) it is against
> > net-next as of yesterday.
> >
> > AF_BUS is a message oriented inter process communication system.
> >
> > The principle features are:
> >
> >   - Reliable datagram based communication (all sockets are of type
> >     SOCK_SEQPACKET)
> >
> >   - Multicast message delivery (one to many, unicast as a subset)
> >
> >   - Strict ordering (messages are delivered to every client in the same order)
> >
> >   - Ability to pass file descriptors
> >
> >   - Ability to pass credentials
> >
> 
> I haven't had time to look at the code yet, but if you haven't already 
> I'd like to propose adding the ability for someone with suitable 
> privileges to eavesdrop on all communications.  We've been using 
> something similar to this (essentially a simplified multicast unix 
> datagram protocol) for many years now and having a tcpdump-like ability 
> is very useful for debugging.

It's in there (look for 'eavesdrop' in 08/15).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
