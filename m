From: "CIT/Paul" <xerox@foonet.net>
Subject: RE: Route cache performance under stress
Date: Mon, 9 Jun 2003 04:10:55 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <000401c32e5e$a707b6d0$4a00000a@badass>
References: <20030609071330.GD20613@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@redhat.com>, <hadi@shell.cyberus.ca>,
	<fw@deneb.enyo.de>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "'Simon Kirby'" <sim@netnation.com>
In-Reply-To: <20030609071330.GD20613@netnation.com>
List-Id: netdev.vger.kernel.org

I've got juno-z.101f.c to send 500,000 pps at 300+mbit on our dual p3
1.26 ghz routers.. I can't even send 50mbit of this though one of my
routers
Without it using 100% of both cpus because of the route cache.. It goes
up to 500,000 entries if I let it and it adds 80,000 new entries per
second and they are all cache misses.. I'd be glad to show you the setup
sometime :) I showed it to jamal and we tested some stuff.

Paul xerox@foonet.net http://www.httpd.net


-----Original Message-----
From: Simon Kirby [mailto:sim@netnation.com] 
Sent: Monday, June 09, 2003 3:14 AM
To: CIT/Paul
Cc: 'David S. Miller'; hadi@shell.cyberus.ca; fw@deneb.enyo.de;
netdev@oss.sgi.com; linux-net@vger.kernel.org
Subject: Re: Route cache performance under stress


On Mon, Jun 09, 2003 at 02:28:30AM -0400, CIT/Paul wrote:

> OK so let's try this.. If you can show me a linux router can can route

> 100mbps or more of juno-z.101f.c attack without dropping packets I 
> will be thoroughly impressed  :)
> 
> I am willing to test out any code/patches and settings that you can 
> think of and post some results..

I'll see if I can set up a test bed this week.  I think we should
already be able to do close to this, but I'll let the numbers will do
the talking. :)

In the tests I've been doing so far, I've been dropping responses (in
the INPUT chain), so I haven't been testing the forwarding through of
packets (though it is testing the routing input).  I'll see if I can set
up a router, target, and DoS box.

I haven't been able to get juno-z.101f.c to saturate 100 Mbit/sec
outgoing, but I've only tried it on eepro100 boxes.  Has anybody got it
to send more?  Mmm, need more tg3 cards...

Simon-

