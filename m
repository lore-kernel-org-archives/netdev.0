From: Dorn Hetzel <kernel@dorn.hetzel.org>
Subject: Re: r8169.c
Date: Mon, 22 Nov 2004 13:13:07 -0500
Message-ID: <20041122181307.GA3625@lilah.hetzel.org>
References: <20041119162920.GA26836@lilah.hetzel.org> <20041119201203.GA13522@electric-eye.fr.zoreil.com> <20041120003754.GA32133@lilah.hetzel.org> <20041120002946.GA18059@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dorn Hetzel <kernel@dorn.hetzel.org>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20041120002946.GA18059@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Nov 20, 2004 at 01:29:46AM +0100, Francois Romieu wrote:
> Dorn Hetzel <kernel@dorn.hetzel.org> :
> 
> You have two options (or more) on top of 2.6.10-rc2:
> - ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.10-rc2/2.6.10-rc2-mm2/2.6.10-rc2-mm2.bz2
> - http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.10-rc2-netdev1.patch.bz2
>
I have gotten as far as rc2-mm2, which was a fairly complete failure.  After
just a couple of pings on the interface, the whole system started to freeze
up fairly hard.  Please see   http://www.hetzel.org/8169/rc2-mm2/   for a
set of information on the system state this time around.  The last two
lines in messages.txt are:

illyria kernel: NETDEV WATCHDOG: eth0: transmit timed out
illyria kernel: eth0: interrupt 0001 taken in poll

Then things go south pretty hard and fast...

I'll try the other patches on top of rc2-mm2 tonight and see if that turns
out any better :)

> Once you have applied one of the patch above, the patch below will improve
> your "transmit timed out" (please apply in order and enable NAPI):
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.10-rc2-mm1/r8169-250.patch
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.10-rc2-mm1/r8169-255.patch
> 
> If things perform better you may want to use bigger frames and apply as
> well r8169-260.patch and r8169-265.patch.
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.10-rc2-mm1/r8169-260.patch
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.10-rc2-mm1/r8169-265.patch
>

Thanks again for all your help!

-Dorn
 
