From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/3 net-next] tg3: Add sysfs file to export sensor
 data
Date: Mon, 25 Jun 2012 14:04:18 -0700
Message-ID: <1340658258.4344.43.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1340237192-30052-1-git-send-email-mchan@broadcom.com>
 <1340237192-30052-2-git-send-email-mchan@broadcom.com>
 <1340237192-30052-3-git-send-email-mchan@broadcom.com>
 <20120622.172651.932738000786251092.davem@davemloft.net>
 <1340413453.4344.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <1340463729.6345.25.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	nsujir@broadcom.com, mcarlson@broadcom.com
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3639 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755516Ab2FYVEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 17:04:32 -0400
In-Reply-To: <1340463729.6345.25.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-06-23 at 16:02 +0100, Ben Hutchings wrote: 
> Temperature and voltage can be exposed through an hwmon device (which
> practically means you use multiple attributes with conventional names).
> Other diagnostics might possible be suitable for ethtool stats,
> depending on what they are.

I think we can extract some common and more useful attributes such as
temperature and voltage, and use the standard hwmon attributes to expose
them.

> 
> If the driver can't easily parse the information (e.g. it varies greatly
> between the different chips and firmware versions) then a binary
> attribute or private ioctl might be appropriate.  But generic interfaces
> really should be considered first.
> 

The rest of the bulk data requires too much parsing in the kernel and
will have to be exposed as binary data.  What do you mean by binary
attribute?  A new binary sysfs attribute under hwmon?  Or outside of
hwmon?  And please elaborate on the private ioctl.

Thanks.
