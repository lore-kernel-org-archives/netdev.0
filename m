From: bert hubert <ahu@ds9a.nl>
Subject: Re: 3c59x 2.4.18 userspace seeing UDP packets with bad checksum?
Date: Tue, 30 Jul 2002 16:12:37 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020730141237.GA26712@outpost.ds9a.nl>
References: <20020730134908.GA26100@outpost.ds9a.nl> <Pine.LNX.4.44.0207301002370.1266-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, akpm@zip.com.au,
   jgarzik@mandrakesoft.com
Return-path: <owner-netdev@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0207301002370.1266-100000@beohost.scyld.com>
List-Id: netdev.vger.kernel.org

On Tue, Jul 30, 2002 at 10:09:13AM -0400, Donald Becker wrote:

> > We fixed the bug already :-) Signed/unsigned arithmetic problems.
> 
> Were the arithmetic problems in your code, or the kernels checksumming?
> (The latter seems unlikely.)

We fixed *our* bug. I would never want to rely on checksums for input
validation :-) Our code should handle everything people care to throw at it
and I think that right now, it will.

> This is a good time to fix your application data validity checking.

Has been done. Watch freshmeat for the update :-)

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://www.tk                              the dot in .tk
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
