From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 20 May 2005 16:11:07 -0700
Message-ID: <1116630667.31523.45.camel@rh4>
References: <20050520194220.GA18259@havoc.gtf.org>
 <20050520.152836.48528379.davem@davemloft.net>
 <428E72F9.3070404@pobox.com>
 <20050520.164504.31639000.davem@davemloft.net>
 <428E7A53.1030907@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S.Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        ffan@broadcom.com, lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>
In-Reply-To: <428E7A53.1030907@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-05-20 at 20:01 -0400, Jeff Garzik wrote:
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
> 

Yes, if the UDP checksum field in the UDP header is zero - meaning
checksum is not calculated for this packet, the calculated checksum done
by the chip will almost always be something other than 0xffff, and so it
will end up with CHECKSUM_NONE.
