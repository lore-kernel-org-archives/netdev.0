From: Adrian Bunk <bunk@stusta.de>
Subject: How to handle the multiple aes variants on i386?
Date: Thu, 3 Mar 2005 16:07:30 +0100
Message-ID: <20050303150730.GA4608@stusta.de>
References: <20050226113123.GJ3311@stusta.de> <42256078.1040002@pobox.com> <20050302140833.GD4608@stusta.de> <42261004.4000501@pobox.com> <20050302123829.51dbc44b.akpm@osdl.org> <42262B08.2040401@pobox.com> <20050302131817.2e61805f.akpm@osdl.org> <4226412E.6070403@pobox.com> <20050302224550.GJ4608@stusta.de> <422642F6.5040102@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, jmorris@redhat.com, davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <422642F6.5040102@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 02, 2005 at 05:49:26PM -0500, Jeff Garzik wrote:
> Adrian Bunk wrote:
> >On Wed, Mar 02, 2005 at 05:41:50PM -0500, Jeff Garzik wrote:
>...
> >>Not really that easy.  For x86 we have
> >>
> >>	aes
> >>	aes-586
> >>	aes-via
> >
> >
> >Where is aes-via?
> 
> drivers/crypto
> 
> 
> >>And my own personal custom-kernel preference is to use the C version of 
> >>the code on my x86 and x86-64 boxes.
> >
> >
> >That's already not possible today.
> 
> It should be.

OK, rethinking about it, your arguments sound reasonable.

Could anyone explain, what exactly happens if multiple "aes" algorithms 
are compiled into the kernel?

Choosing between the i386 asm and the generic versions seems easy, bug 
the VIA Padlock case sounds more tricky since it works only on a subset 
of the i386 architecture.

> 	Jeff

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
