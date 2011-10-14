From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] staging: hv: move hv_netvsc out of staging area
Date: Fri, 14 Oct 2011 13:16:05 -0600
Message-ID: <20111014191605.GA31039@suse.de>
References: <1318620026-8349-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kys@microsoft.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, virtualization@lists.osdl.org,
	Mike Sterling <Mike.Sterling@microsoft.com>,
	NetDev <netdev@vger.kernel.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1318620026-8349-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 14, 2011 at 12:20:26PM -0700, Haiyang Zhang wrote:
> hv_netvsc has been reviewed on netdev mailing list on 6/09/2011.
> All recommended changes have been made. We are requesting to move
> it out of staging area.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Signed-off-by: KY Srinivasan <kys@microsoft.com>
> Signed-off-by: Mike Sterling <Mike.Sterling@microsoft.com>
> Cc: NetDev <netdev@vger.kernel.org>
> 
> ---
>  drivers/net/Kconfig                               |    2 ++
>  drivers/net/Makefile                              |    2 ++
>  drivers/net/hyperv/Kconfig                        |    5 +++++
>  drivers/net/hyperv/Makefile                       |    3 +++
>  drivers/{staging/hv => net/hyperv}/hyperv_net.h   |    0
>  drivers/{staging/hv => net/hyperv}/netvsc.c       |    0
>  drivers/{staging/hv => net/hyperv}/netvsc_drv.c   |    0
>  drivers/{staging/hv => net/hyperv}/rndis_filter.c |    0

Because of renames, the network developers really can't review this.  I
suggest posting a new patch, that just adds the driver to the
drivers/net/ directory, and have the network developer review it that
way.

Then, when it is accepted, I can delete the version in the staging
directory.  We've done it this way for other drivers and it is the best
way to get proper reviews as well as handling cross-subsystem merge
issues.

thanks,

greg k-h
