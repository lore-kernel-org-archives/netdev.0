From: Greg KH <gregkh@suse.de>
Subject: Re: Request for review on Hyper-V virtual network driver
Date: Thu, 9 Jun 2011 15:07:01 -0700
Message-ID: <20110609220701.GA24006@suse.de>
References: <1307654865-30326-1-git-send-email-haiyangz@microsoft.com>
 <1307655530.13329.49.camel@Joe-Laptop>
 <A1F3067C9B68744AA19F6802BAB8FFDC09603E8F@TK5EX14MBXC227.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	Hank Janssen <hjanssen@microsoft.com>,
	KY Srinivasan <kys@microsoft.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:58775 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755588Ab1FIWHN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 18:07:13 -0400
Content-Disposition: inline
In-Reply-To: <A1F3067C9B68744AA19F6802BAB8FFDC09603E8F@TK5EX14MBXC227.redmond.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 09, 2011 at 09:59:19PM +0000, Haiyang Zhang wrote:
> > -----Original Message-----
> > From: Joe Perches [mailto:joe@perches.com]
> > Sent: Thursday, June 09, 2011 5:39 PM
> > >  create mode 100644 drivers/net/hyperv/netvsc.c
> > >  create mode 100644 drivers/net/hyperv/netvsc_drv.c
> > >  create mode 100644 drivers/net/hyperv/rndis_filter.c
> > >  delete mode 100644 drivers/staging/hv/hyperv_net.h
> > >  delete mode 100644 drivers/staging/hv/netvsc.c
> > >  delete mode 100644 drivers/staging/hv/netvsc_drv.c
> > >  delete mode 100644 drivers/staging/hv/rndis_filter.c
> > 
> > I suggest you resend this using the -M or --find-renames option.
> 
> Will do.

No, that will not show anything at all, which is the point of the
review.  Otherwise it will just require someone to go look at the
drivers/staging/hv/ directory in linux-next to properly determine what
is happening here.

So this patch is fine for a review.

thanks,

greg k-h
