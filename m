From: Richard Gooch <rgooch@ras.ucalgary.ca>
Subject: Re: [PATCH] 2.4.20-pre sundance.c cleanups
Date: Thu, 19 Sep 2002 00:42:59 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209190642.g8J6gxX29989@vindaloo.ras.ucalgary.ca>
References: <20020828185612.GA14342@reflexsecurity.com>
	<20020828231333.GA15183@reflexsecurity.com>
	<200209190353.g8J3r5q28456@vindaloo.ras.ucalgary.ca>
	<20020919041403.GA10527@orr.falooley.org>
Cc: netdev@oss.sgi.com, becker@scyld.com, jgarzik@mandrakesoft.com,
   "Patrick R. McManus" <mcmanus@ducksong.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <20020919041403.GA10527@orr.falooley.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jason Lunz writes:
> On Wed, Sep 18, 2002 at  9:53PM -0600, Richard Gooch wrote:
> > - the driver is reporting 10 Mbps rather than 100 Mbps. I've actually
> >   measured eth0 and eth2 and these are delivering 100 Mbps
> 
> i've noticed this too, and it's probably from all the mucking about
> I did trying to combine becker's method of forcing duplex/speed with
> the one in 2.4.19. That stuff is unrelated to the other,
> more-important merges I did that actually affect how well the card
> works. Jeff rightly pointed out that I should separate out chunks of
> the patch for submission, but I haven't had time.

Speaking of forcing speeds, is the following in /etc/modules.conf
supposed to work? Did I get the syntax right?
  options         sundance        media="autosense","100mbps_fd","autosense"

> This card is still nowhere near working well, even with my patch. It
> silently drops many frames when simultaneously sending and receiving
> at high packet rates. It also locks up under load, and is reset in
> tx_timeout. This happens less frequently with my patch, but is not
> entirely gone.

Ah, that might explain why I've seen variations in TCP throughput from
eth0 <-> eth2 ranging from <8 MB/s to >11 MB/s.

About these lockups: are they fully recoverable by the driver, or does
the machine need attention to fix this? If the former, how long before
the driver recovers?

				Regards,

					Richard....
Permanent: rgooch@atnf.csiro.au
Current:   rgooch@ras.ucalgary.ca
