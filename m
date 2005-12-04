From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [-mm patch] remove code for WIRELESS_EXT < 18
Date: Sun, 4 Dec 2005 20:52:07 +0100
Message-ID: <20051204195207.GA9973@stusta.de>
References: <20051203122720.GF31395@stusta.de> <4393447E.3020003@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932326AbVLDTwL@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4393447E.3020003@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 04, 2005 at 02:33:18PM -0500, Jeff Garzik wrote:
> Adrian Bunk wrote:
> >WIRELESS_EXT < 18 will never be true in the kernel.
> >
> >
> >Signed-off-by: Adrian Bunk <bunk@stusta.de>
> >
> >---
> >
> > drivers/net/wireless/ipw2100.c           |  434 ----------------------
> > drivers/net/wireless/tiacx/acx_struct.h  |    5 
> > drivers/net/wireless/tiacx/common.c      |    4 
> > drivers/net/wireless/tiacx/conv.c        |    2 
> > drivers/net/wireless/tiacx/ioctl.c       |  441 -----------------------
> > drivers/net/wireless/tiacx/pci.c         |    8 
> > drivers/net/wireless/tiacx/usb.c         |    6 
> > drivers/net/wireless/tiacx/wlan.c        |    2 
> > drivers/net/wireless/tiacx/wlan_compat.h |    9 
> > 9 files changed, 1 insertion(+), 910 deletions(-)
> 
> NAK, patches non-existent files.
> 
> [jgarzik@pretzel linux-2.6]$ ls drivers/net/wireless/tiacx
> ls: drivers/net/wireless/tiacx: No such file or directory

As the subject says, it's against -mm.

How should I resend it?
One patch against ipw2100.c and one patch for the tiacx stuff?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
