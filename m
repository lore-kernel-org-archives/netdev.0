From: Donald Becker <becker@scyld.com>
Subject: Re: raw ipv6 broken in 2.4.19
Date: Wed, 14 Aug 2002 08:15:47 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0208140812570.3936-100000@beohost.scyld.com>
References: <200208132006.AAA21878@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Martin Josefsson <gandalf@wlug.westbo.se>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200208132006.AAA21878@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Wed, 14 Aug 2002 kuznet@ms2.inr.ac.ru wrote:

> Actually, tulip is really different of another cards, this creature
> generates badly aligned packets. F.e. it is possible a checksumming routine
> folds some bytes beyond end of frame. :-) I have lots of verious tulips here,
> but have never seen such a shit. :-)

I'm not certain what you mean by this: there are many NIC chips that have
alignment requirements similar to the Tulip design.

Note that the Tulip is no more likely than other cards to trigger
motherboard PCI implementation bugs.  It's just that there are far more
NIC chip types supported by the Tulip driver than other drivers.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Second Generation Beowulf Clusters
Annapolis MD 21403			410-990-9993
