From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: [Bonding-devel] Re: Changing bonding <-> ifenslave interface [was: Problem with current /proc entries]
Date: Mon, 20 Oct 2003 17:21:23 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031020212123.GA98298@calma.pair.com>
References: <shmulik.hen@intel.com> <200310202020.57503.shmulik.hen@intel.com> <200310201912.h9KJCo7A027272@death.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shmulik.hen@intel.com, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200310201912.h9KJCo7A027272@death.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> 	In the past, I'd thought this (a bonding-utils package for
> ifenslave) wasn't an especially good idea, because I didn't really see
> much advantage for us in doing it.  Now, it looks like it is to our
> advantage to have just one ifenslave development line, distinct from
> the kernel development line (if the single ifenslave will be going
> both ways there's no reason to keep two separate copies in the 2.4 and
> 2.6 kernel trees).
> 
> 	I really do like having ifenslave right there in the kernel
> source, it's very handy, but it may be better overall to pull it out
> and distribute it separately.
> 
> 	Comments?  Chad, you out there?  I know you really like having
> ifenslave in the kernel source; what do you think about this?

I have had many numerous users email me specifically to say that they like
to have the ifenslave.c in the kernel.  They know that no matter what, when
they upgrade their kernel, they can simply compile the ifenslave that is there
and it will work.  They don't want to have to go hunt around on some website
to try to find a working ifenslave. 

In contrast, I have seen nothing but pain when trying to separate userspace
from kernel space.  Trying to get the right iputils package to match up
with the kernel you are using is a pain; and it makes the iputils stuff
just that much harder to maintain, for the same reasons we're discussing.

I have never heard of anyone complaining that ifenslave.c is packaged
with the kernel source.  

Chad
