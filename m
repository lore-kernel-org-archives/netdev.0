From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/3 net-next] tg3: Add sysfs file to export sensor
 data
Date: Fri, 22 Jun 2012 18:04:13 -0700
Message-ID: <1340413453.4344.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1340237192-30052-1-git-send-email-mchan@broadcom.com>
 <1340237192-30052-2-git-send-email-mchan@broadcom.com>
 <1340237192-30052-3-git-send-email-mchan@broadcom.com>
 <20120622.172651.932738000786251092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com, mcarlson@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4399 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756848Ab2FWBEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2012 21:04:30 -0400
In-Reply-To: <20120622.172651.932738000786251092.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-22 at 17:26 -0700, David Miller wrote: 
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Wed, 20 Jun 2012 17:06:32 -0700
> 
> > Some tg3 devices have management firmware that can export data such as
> > temperature and other real time diagnostics data.  Export this data to
> > sysfs so that userspace can access this information.
> > 
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> I do not agree that sysfs is the appropriate place to export binary
> data.
> 

What's your suggestion?  ethtool?
