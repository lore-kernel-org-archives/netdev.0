From: Dorn Hetzel <kernel@dorn.hetzel.org>
Subject: Re: r8169.c
Date: Thu, 25 Nov 2004 19:36:14 -0500
Message-ID: <20041126003614.GA5441@lilah.hetzel.org>
References: <20041119162920.GA26836@lilah.hetzel.org> <20041119201203.GA13522@electric-eye.fr.zoreil.com> <20041120003754.GA32133@lilah.hetzel.org> <20041120002946.GA18059@electric-eye.fr.zoreil.com> <20041122181307.GA3625@lilah.hetzel.org> <20041123144901.GA19005@lilah.hetzel.org> <20041123194740.GA32210@electric-eye.fr.zoreil.com> <20041125220233.GA23850@lilah.hetzel.org> <20041125205411.GA3204@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dorn Hetzel <kernel@dorn.hetzel.org>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20041125205411.GA3204@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


It did *build* well enough not to blow up the kernel build with 2.95.4,
it just failed in use...

On Thu, Nov 25, 2004 at 09:54:11PM +0100, Francois Romieu wrote:
> Dorn Hetzel <kernel@dorn.hetzel.org> :
> [...]
> > I went ahead and remotely rebuilt using gcc 2.95.4 and upon reboot it
> > worked long enough to ssh in and then it failed.  So it sounds like the
> > version of gcc DOES make a difference :)
> 
> Ok, I'll have to audit the driver for the typical inline assembler +
> arithmetic ops which 2.95.x dislikes.
> 
> --
> Ueimor
