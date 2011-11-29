From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] staging: hv: move hv_netvsc out of staging area
Date: Wed, 30 Nov 2011 00:16:38 +0900
Message-ID: <20111129151638.GB24688@kroah.com>
References: <1322516135-22221-1-git-send-email-haiyangz@microsoft.com>
 <A1F3067C9B68744AA19F6802BAB8FFDC0CCCC087@TK5EX14MBXC227.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "gregkh@suse.de" <gregkh@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	NetDev <netdev@vger.kernel.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <A1F3067C9B68744AA19F6802BAB8FFDC0CCCC087@TK5EX14MBXC227.redmond.corp.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2011 at 10:00:35PM +0000, Haiyang Zhang wrote:
> > -----Original Message-----
> > From: Haiyang Zhang [mailto:haiyangz@microsoft.com]
> > Sent: Monday, November 28, 2011 4:36 PM
> > To: Haiyang Zhang; KY Srinivasan; gregkh@suse.de; linux-
> > kernel@vger.kernel.org; devel@linuxdriverproject.org
> > Cc: Mike Sterling; NetDev
> > Subject: [PATCH] staging: hv: move hv_netvsc out of staging area
> > 
> > hv_netvsc has been reviewed on netdev mailing list on 6/09/2011.
> > All recommended changes have been made. We are requesting to move it
> > out of staging area.
> > 
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Signed-off-by: KY Srinivasan <kys@microsoft.com>
> > Signed-off-by: Mike Sterling <Mike.Sterling@microsoft.com>
> > Cc: NetDev <netdev@vger.kernel.org>
> > Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> > ---
> >  drivers/net/Kconfig                               |    2 ++
> >  drivers/net/Makefile                              |    2 ++
> >  drivers/net/hyperv/Kconfig                        |    5 +++++
> >  drivers/net/hyperv/Makefile                       |    3 +++
> >  drivers/{staging/hv => net/hyperv}/hyperv_net.h   |    0
> >  drivers/{staging/hv => net/hyperv}/netvsc.c       |    0
> >  drivers/{staging/hv => net/hyperv}/netvsc_drv.c   |    0
> >  drivers/{staging/hv => net/hyperv}/rndis_filter.c |    0
> >  drivers/staging/hv/Kconfig                        |    6 ------
> >  drivers/staging/hv/Makefile                       |    2 --
> >  drivers/staging/hv/TODO                           |    1 -
> >  11 files changed, 12 insertions(+), 9 deletions(-)  create mode 100644
> > drivers/net/hyperv/Kconfig  create mode 100644
> > drivers/net/hyperv/Makefile  rename drivers/{staging/hv =>
> > net/hyperv}/hyperv_net.h (100%)  rename drivers/{staging/hv =>
> > net/hyperv}/netvsc.c (100%)  rename drivers/{staging/hv =>
> > net/hyperv}/netvsc_drv.c (100%)  rename drivers/{staging/hv =>
> > net/hyperv}/rndis_filter.c (100%)
> > 
> 
> I have rebased the previous patch on the latest staging-next branch,
> and re-submitting it now.  In another email, the same patch was
> submitted without using the "-M" flag, in case anyone wants to read
> the unchanged code in the patch body.

This one was fine, now applied, thanks.

greg k-h
