From: Jon Mason <jon.mason@intel.com>
Subject: Re: [PATCH 14/21] NTB: Fix Sparse Warnings
Date: Mon, 21 Jan 2013 15:28:46 -0700
Message-ID: <20130121222846.GK22208@jonmason-lab>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
 <1358586155-23322-15-git-send-email-jon.mason@intel.com>
 <20130120234534.GD14196@kroah.com>
 <20130121211350.GH22208@jonmason-lab>
 <20130121213719.GA20506@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130121213719.GA20506@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 21, 2013 at 01:37:19PM -0800, Greg KH wrote:
> On Mon, Jan 21, 2013 at 02:13:50PM -0700, Jon Mason wrote:
> > On Sun, Jan 20, 2013 at 03:45:34PM -0800, Greg KH wrote:
> > > On Sat, Jan 19, 2013 at 02:02:28AM -0700, Jon Mason wrote:
> > > > Address the sparse warnings and resulting fallout
> > > > 
> > > > Signed-off-by: Jon Mason <jon.mason@intel.com>
> > > > ---
> > > >  drivers/ntb/ntb_hw.c        |    7 ++++---
> > > >  drivers/ntb/ntb_hw.h        |    4 ++--
> > > >  drivers/ntb/ntb_transport.c |   32 ++++++++++++++++----------------
> > > >  3 files changed, 22 insertions(+), 21 deletions(-)
> > > > 
> > > > diff --git a/drivers/ntb/ntb_hw.c b/drivers/ntb/ntb_hw.c
> > > > index 18cb5dc..b792ccd 100644
> > > > --- a/drivers/ntb/ntb_hw.c
> > > > +++ b/drivers/ntb/ntb_hw.c
> > > > @@ -104,8 +104,9 @@ MODULE_DEVICE_TABLE(pci, ntb_pci_tbl);
> > > >   *
> > > >   * RETURNS: An appropriate -ERRNO error value on error, or zero for success.
> > > >   */
> > > > -int ntb_register_event_callback(struct ntb_device *ndev,
> > > > -				void (*func)(void *handle, unsigned int event))
> > > > +int
> > > > +ntb_register_event_callback(struct ntb_device *ndev,
> > > > +			    void (*func)(void *handle, enum ntb_hw_event event))
> > > 
> > > What is sparse complaining about here that moving the function name to
> > > the start of the line fixes?  That shouldn't be necessary at all.  Ah,
> > > the enum?  If so, why change the first line at all?
> > 
> > All an effort to get it to fit in under 80 chars.
> 
> The original lines were less than 80 characters :)
> 
> > > > --- a/drivers/ntb/ntb_transport.c
> > > > +++ b/drivers/ntb/ntb_transport.c
> > > > @@ -58,7 +58,7 @@
> > > >  #include <linux/ntb.h>
> > > >  #include "ntb_hw.h"
> > > >  
> > > > -#define NTB_TRANSPORT_VERSION	1
> > > > +#define NTB_TRANSPORT_VERSION	2
> > > 
> > > How is this a sparse fix?
> > 
> > I changed the format of the header below.
> 
> Ah, ok.
> 
> Care to resend this without the first chunk?

Works for me :)

Resending with the minor edit now.

Thanks,
Jon

> 
> thanks,
> 
> greg k-h
