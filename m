From: Maxim <maximlevitsky@gmail.com>
Subject: Re: [PATCH] MAINTAINERS: no DMFE maintainer
Date: Sun, 11 Feb 2007 23:19:41 +0200
Message-ID: <200702112319.41865.maximlevitsky@gmail.com>
References: <20070209143106.9dc30c9b.randy.dunlap@oracle.com> <45CCF978.40006@garzik.org> <20070209145404.d317a496.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev <netdev@vger.kernel.org>,
	tori@unhappy.mine.nu, Levitsky Maxim <maximlevitsky@yahoo.com>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:8643 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbXBKVTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Feb 2007 16:19:49 -0500
Received: by ug-out-1314.google.com with SMTP id 44so412689uga
        for <netdev@vger.kernel.org>; Sun, 11 Feb 2007 13:19:48 -0800 (PST)
In-Reply-To: <20070209145404.d317a496.randy.dunlap@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 10 February 2007 00:54:04 Randy Dunlap wrote:
> On Fri, 09 Feb 2007 17:45:12 -0500 Jeff Garzik wrote:
> > Randy Dunlap wrote:
> > > From: Randy Dunlap <randy.dunlap@oracle.com>
> > >
> > > Tobias wrote that he no longer maintains this driver and requested
> > > to be removed from MAINTAINERS.
> > >
> > > Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> > > ---
> > >  MAINTAINERS |    4 +---
> > >  1 file changed, 1 insertion(+), 3 deletions(-)
> >
> > Levitsky Maxim <maximlevitsky@yahoo.com> just posted a bunch of patches
> > to the dmfe driver, maybe you could ping him?
>
> Hi Maxim,
> What do you think about this patch to the MAINTAINERS file
> based on your recent DMFE patch history?
>
> ---
>
> From: Randy Dunlap <randy.dunlap@oracle.com>
>
> Tobias wrote that he no longer maintains this driver and requested
> to be removed from MAINTAINERS.  However, Levitsky Maxim has been
> active on DMFE recently.
>
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  MAINTAINERS |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> --- linux-2.6.20-git5.orig/MAINTAINERS
> +++ linux-2.6.20-git5/MAINTAINERS
> @@ -1112,8 +1112,8 @@ T:	git kernel.org:/pub/scm/linux/kernel/
>  S:	Supported
>
>  DAVICOM FAST ETHERNET (DMFE) NETWORK DRIVER
> -P:	Tobias Ringstrom
> -M:	tori@unhappy.mine.nu
> +P:	Levitsky Maxim
> +M:	maximlevitsky@yahoo.com
>  L:	netdev@vger.kernel.org
>  S:	Maintained
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Hello , I agree with it.


Recently I have studied this driver to fix suspend/resume ( it always woke my 
system from stand-by , so I had to unload it to make standby work)

I have read whole documentation of this chip and I found that WOL and link 
detection is missing so I added them too.

So I feel ok to be maintainer of this driver

Regards, Maxim Levitsky

