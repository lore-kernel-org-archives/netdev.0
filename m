From: Jason Lunz <lunz@falooley.org>
Subject: Re: [PATCH] 2.4.20-pre sundance.c cleanups
Date: Thu, 19 Sep 2002 00:14:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020919041403.GA10527@orr.falooley.org>
References: <20020828185612.GA14342@reflexsecurity.com> <20020828231333.GA15183@reflexsecurity.com> <200209190353.g8J3r5q28456@vindaloo.ras.ucalgary.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, becker@scyld.com, jgarzik@mandrakesoft.com,
   "Patrick R. McManus" <mcmanus@ducksong.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Gooch <rgooch@ras.ucalgary.ca>
Content-Disposition: inline
In-Reply-To: <200209190353.g8J3r5q28456@vindaloo.ras.ucalgary.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 18, 2002 at  9:53PM -0600, Richard Gooch wrote:
> - the driver is reporting 10 Mbps rather than 100 Mbps. I've actually
>   measured eth0 and eth2 and these are delivering 100 Mbps

i've noticed this too, and it's probably from all the mucking about I
did trying to combine becker's method of forcing duplex/speed with the
one in 2.4.19. That stuff is unrelated to the other, more-important
merges I did that actually affect how well the card works. Jeff rightly
pointed out that I should separate out chunks of the patch for
submission, but I haven't had time.

This card is still nowhere near working well, even with my patch. It
silently drops many frames when simultaneously sending and receiving at
high packet rates. It also locks up under load, and is reset in
tx_timeout. This happens less frequently with my patch, but is not
entirely gone.

Also, I need to investigate yet another variation on this driver, as
pointed out in
http://www.ussg.iu.edu/hypermail/linux/kernel/0209.0/1107.html

Jason
