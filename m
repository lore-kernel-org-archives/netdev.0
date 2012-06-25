From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/3 net-next] tg3: Add sysfs file to export sensor
 data
Date: Mon, 25 Jun 2012 14:50:35 -0700
Message-ID: <1340661035.4344.53.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1340237192-30052-1-git-send-email-mchan@broadcom.com>
 <1340237192-30052-2-git-send-email-mchan@broadcom.com>
 <1340237192-30052-3-git-send-email-mchan@broadcom.com>
 <20120622.172651.932738000786251092.davem@davemloft.net>
 <1340413453.4344.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <1340463729.6345.25.camel@deadeye.wl.decadent.org.uk>
 <1340658258.4344.43.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <1340659554.2572.52.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	nsujir@broadcom.com, mcarlson@broadcom.com
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4335 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756024Ab2FYVut (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 17:50:49 -0400
In-Reply-To: <1340659554.2572.52.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-25 at 22:25 +0100, Ben Hutchings wrote: 
> > The rest of the bulk data requires too much parsing in the kernel and
> > will have to be exposed as binary data.  What do you mean by binary
> > attribute?  A new binary sysfs attribute under hwmon?  Or outside of
> > hwmon?
> 
> A binary sysfs attribute under your PCI device.  (In fact, for wider
> userland compatibility, hwmon sysfs attributes should also be under the
> PCI device rather than the hwmon device.  Yes, this *is* a weird
> convention.)
> 
> > And please elaborate on the private ioctl.
> 
> Every driver gets to handle SIOCDEVPRIVATE .. SIOCDEVPRIVATE+15.  But
> avoid the first 3, as userland may blindly try to use them for MDIO.
> David may of course tell you that you should under no circumstances
> actually do this. 

Yeah, we won't touch SIOCDEVPRIVATE with a 10-foot pole.
