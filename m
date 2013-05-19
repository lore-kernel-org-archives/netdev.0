From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/5] drivers: net: usb: rtl8150: bug fixing and cleanup
Date: Sun, 19 May 2013 21:01:16 +0200
Message-ID: <20130519190116.GA4019@electric-eye.fr.zoreil.com>
References: <alpine.DEB.2.02.1305181902080.7518@fry.nucleusys.com>
 <20130518210948.GA26590@electric-eye.fr.zoreil.com>
 <alpine.DEB.2.02.1305191136360.4537@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1305191136360.4537@fry.nucleusys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Petko Manolov <petkan@nucleusys.com> :
> On Sat, 18 May 2013, Francois Romieu wrote:
> > > From: Petko Manolov <petkan@nucleusys.com>
[...]
> > > Moving constant and structure definitions out of rtl8150.c;
> > 
> > What's the point ?
> 
> The general logic of having .h files applies.

Which one ?
- share it through the kernel or with userspace
- personal choice .c split

I don't mind the later even if it does not exactly apply to a
WIP driver. I'd still avoid future copycat followers though.

[...]
> > >  drivers/net/usb/rtl8150.c |  121 +----------------------------------
> > >  1 file changed, 2 insertions(+), 119 deletions(-)
> > > 
> > > diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
> > > index a491d3a..7d1897b 100644
> > > --- a/drivers/net/usb/rtl8150.c
> > > +++ b/drivers/net/usb/rtl8150.c
> > > @@ -17,132 +17,15 @@
> > >  #include <linux/usb.h>
> > >  #include <asm/uaccess.h>
> > >  
> > > +#include "rtl8150.h"
> > 
> > It won't compile. You shouldn't do that.
> 
> It does compile.  Both inside and outside of the tree.

The rtl8150.h file is created in patch #2. This is patch #1.

So...

-- 
Ueimor
