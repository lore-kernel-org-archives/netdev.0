From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Dealing with buggy hardware (was: b44 and 4g4g)
Date: Thu, 10 Jun 2004 23:12:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040610211217.GA6634@elf.ucw.cz>
References: <20040531202104.GA8301@ee.oulu.fi> <20040605200643.GA2210@ee.oulu.fi> <20040605131923.232f8950.davem@redhat.com> <20040609122905.GA12715@ee.oulu.fi> <20040610200504.GG4507@openzaurus.ucw.cz> <20040610203442.GA27762@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
Content-Disposition: inline
In-Reply-To: <20040610203442.GA27762@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

> > This should hit machines with 2GB ram too, right?
> > Is it possible to find if it hits me? I get hard lockups on
> > 2GB machine with b44, but they take ~5min.. few hours to
> > reproduce...
> >  
> > It seems to me like this should hit very quickly.
> > -- 
> > 64 bytes from 195.113.31.123: icmp_seq=28 ttl=51 time=448769.1 ms         
> > 
> Yikes!
> 
> With the 4:4 VM split it definately is instantaneous with > 1GB of memory, I
> triggered it with 1.25G myself and never noticed anything wrong with just
> 1GB (allocation starts from the top it seems). With the standard 1:3 split I
> don't think anything > 1GB ever gets used for skbuffs, but maybe there
> are circumstances where this can happen? 

Okay, this is probably other problem. When the bug hit, what are the symptoms?

> (Or the issue isn't fully understood yet, figuring out what breaks and what
> doesn't was basically just trial and error :-/ )

Can you try the driver from broadcom? bcom4400, or how is it
called. Its extremely ugly, but might get this kind of stuff right...

								Pavel
-- 
People were complaining that M$ turns users into beta-testers...
...we turn them into developers, and they seem to like it that way!
