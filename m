From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 00:13:30 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609071330.GD20613@netnation.com>
References: <20030608.225837.115923841.davem@redhat.com> <001801c32e50$57ef0750$4a00000a@badass>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'David S. Miller'" <davem@redhat.com>, hadi@shell.cyberus.ca,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: CIT/Paul <xerox@foonet.net>
Content-Disposition: inline
In-Reply-To: <001801c32e50$57ef0750$4a00000a@badass>
List-Id: netdev.vger.kernel.org

On Mon, Jun 09, 2003 at 02:28:30AM -0400, CIT/Paul wrote:

> OK so let's try this.. If you can show me a linux router can can route
> 100mbps or more of juno-z.101f.c attack without dropping packets I will
> be thoroughly impressed  :)
> 
> I am willing to test out any code/patches and settings that you can
> think of and post some results..

I'll see if I can set up a test bed this week.  I think we should already
be able to do close to this, but I'll let the numbers will do the
talking. :)

In the tests I've been doing so far, I've been dropping responses (in the
INPUT chain), so I haven't been testing the forwarding through of packets
(though it is testing the routing input).  I'll see if I can set up a
router, target, and DoS box.

I haven't been able to get juno-z.101f.c to saturate 100 Mbit/sec
outgoing, but I've only tried it on eepro100 boxes.  Has anybody got it
to send more?  Mmm, need more tg3 cards...

Simon-
