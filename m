From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/3] device.h drivers/base/core.c Convert dev_<level>
 macros to functions
Date: Thu, 04 Mar 2010 23:23:35 -0800
Message-ID: <1267773815.2136.10.camel@Joe-Laptop.home>
References: <cover.1267771398.git.joe@perches.com>
	 <e18f5d8b8a0857a07918107f464a653234a47564.1267771398.git.joe@perches.com>
	 <20100304231047.4d76e0ef.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1420 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754670Ab0CEHXh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Mar 2010 02:23:37 -0500
In-Reply-To: <20100304231047.4d76e0ef.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-03-04 at 23:10 -0800, Andrew Morton wrote:
> On Thu,  4 Mar 2010 22:56:53 -0800 Joe Perches <joe@perches.com> wrote:
> > Perhaps over time the struct and local uses of dev_info should be renamed.
> aww, c'mon.
> y:/usr/src/linux-2.6.33> grep -r '\*dev_info;' . | wc -l
> 30

No doubt I could submit all the required changes in
an hour or so, but some of the maintainers seem
less than open to what they consider "churn".

$ grep -rP --include=*.[ch] -l "dev_info\b\s*[^\(]" *
arch/powerpc/platforms/iseries/dt.c
drivers/usb/host/xhci-dbg.c
drivers/usb/host/xhci.h
drivers/usb/wusbcore/wusbhc.h
drivers/scsi/scsi_devinfo.c
drivers/staging/comedi/drivers/das08_cs.c
drivers/staging/comedi/drivers/ni_daq_dio24.c
drivers/staging/comedi/drivers/quatech_daqp_cs.c
drivers/staging/comedi/drivers/ni_daq_700.c
drivers/staging/comedi/drivers/ni_labpc_cs.c
drivers/staging/comedi/drivers/cb_das16_cs.c
drivers/staging/udlfb/udlfb.c
drivers/media/video/sh_mobile_ceu_camera.c
drivers/md/linear.h
drivers/net/ksz884x.c
drivers/net/bnx2x_link.c
drivers/net/wireless/wl3501_cs.c
drivers/net/cnic.c
drivers/net/bnx2x_main.c
include/linux/sfi.h
include/net/bluetooth/rfcomm.h


