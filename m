From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Thu, 17 Jun 2004 13:39:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617203929.GA3341@bougret.hpl.hp.com>
References: <40D0D265.3070804@pobox.com> <20040617174717.GA30460@bougret.hpl.hp.com> <40D1E185.2010201@pobox.com> <40D1E24C.8090802@pobox.com> <20040617185815.GB32216@bougret.hpl.hp.com> <40D1EAD9.6090403@pobox.com> <20040617191338.GD32216@bougret.hpl.hp.com> <40D1F23E.9090307@pobox.com> <20040617194448.GC31763@bougret.hpl.hp.com> <40D1F9C1.1040907@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Gertjan van Wingerde <gwingerde@home.nl>,
        sfeldma@pobox.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40D1F9C1.1040907@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 17, 2004 at 04:06:25PM -0400, Jeff Garzik wrote:
> 
> >>The general API, yes.  But most driver-private interfaces will fail 
> >>miserably through 32/64-bit translation.
> >
> >
> >	That's fixable, and easy to fix, if needed. You have all the
> >data you need in the kernel.
> 
> Not really -- it's the same problem as SIOCDEVPRIVATE.  Driver-private 
> interfaces by definition change for each driver.  Translation of the 
> same ioctl differs on a per-driver basis.  Consider what happens when 
> passing pointers from userland, for example...

	I can assure you that I thought about that precise issue when
I re-designed the API in 91. I confirm that all the necessary data in
the kernel to do this properly.
	Proof : the "copy_to/from_user" is done in the generic code,
not in the driver. The driver export to the generic code all the data
needed to know where are those user pointers. What else is needed ?

> It was for this reason that we created the MII ioctls, which were 
> previously SIOCDEVPRIVATE.

	Totally different business. Those ioctls were totally
anonymous, with no meta-data.

> 	Jeff

	Jean
