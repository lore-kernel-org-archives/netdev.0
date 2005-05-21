From: "David S. Miller" <davem@davemloft.net>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 20 May 2005 21:28:21 -0700 (PDT)
Message-ID: <20050520.212821.88475745.davem@davemloft.net>
References: <428E72F9.3070404@pobox.com>
	<20050520.164504.31639000.davem@davemloft.net>
	<428E7A53.1030907@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com, ffan@broadcom.com,
        lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <428E7A53.1030907@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 20 May 2005 20:01:23 -0400

> David S.Miller wrote:
> > From: Jeff Garzik <jgarzik@pobox.com>
> > Date: Fri, 20 May 2005 19:30:01 -0400
> > 
> > 
> >>Sure.  What I'm driving at is that a checksum of zero seems to imply 
> >>CHECKSUM_NONE not CHECKSUM_UNNECESSARY.  tg3 only does the 0xffff check.
> > 
> > 
> > Sure, both ways are fine.
> 
> huh?  They are pretty different...  one says "Checksum all good, dude" 
> and the other says "I didn't checksum, do it in software for me."
> 
> right?

0x0000 is the UDP "no checksum" case, so if we say "in software"
for that UDP will just let it pass through still, so the effect
is that same.
