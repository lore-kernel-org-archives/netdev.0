From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Thu, 17 Jun 2004 12:44:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617194448.GC31763@bougret.hpl.hp.com>
References: <40D0BD5B.201@pobox.com> <20040616223316.GA29618@bougret.hpl.hp.com> <40D0D265.3070804@pobox.com> <20040617174717.GA30460@bougret.hpl.hp.com> <40D1E185.2010201@pobox.com> <40D1E24C.8090802@pobox.com> <20040617185815.GB32216@bougret.hpl.hp.com> <40D1EAD9.6090403@pobox.com> <20040617191338.GD32216@bougret.hpl.hp.com> <40D1F23E.9090307@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Gertjan van Wingerde <gwingerde@home.nl>,
        sfeldma@pobox.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40D1F23E.9090307@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 17, 2004 at 03:34:22PM -0400, Jeff Garzik wrote:
> 
> Your patch is half the job -- it allows development of a type-specific 
> interface...

	Which is exactly what you want. Good.

> So while this patch may be useful in early development, it does not 
> allow the direct exposure of core wireless code to the type-specific 
> interfaces

	What is the core wireless code ?

> and as such, it can paper over problems that would be 
> immediately obviously if the type-specific interface were the only one 
> to exist.

	Any new code in the kernel is free to use only the new
API. That's a big enoug incentive to migrate drivers over to the new
API.

> >>Also there is a fourth -- WE doesn't work 100% when you have 
> >>a 32-bit userland and a 64-bit kernel.
> >
> >
> >	Since when ? What made you change your mind ?
> >	Please check :
> >http://marc.theaimsgroup.com/?l=linux-netdev&m=107894322418086&w=2
> 
> The general API, yes.  But most driver-private interfaces will fail 
> miserably through 32/64-bit translation.

	That's fixable, and easy to fix, if needed. You have all the
data you need in the kernel.

> 	Jeff

	Jean
