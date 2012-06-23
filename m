From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/3 net-next] tg3: Add sysfs file to export sensor
 data
Date: Fri, 22 Jun 2012 18:32:26 -0700
Message-ID: <1340415146.4344.24.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1340237192-30052-1-git-send-email-mchan@broadcom.com>
 <1340237192-30052-2-git-send-email-mchan@broadcom.com>
 <1340237192-30052-3-git-send-email-mchan@broadcom.com>
 <20120622175934.2cc253b7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, nsujir@broadcom.com,
	mcarlson@broadcom.com
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1356 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756897Ab2FWBcs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2012 21:32:48 -0400
In-Reply-To: <20120622175934.2cc253b7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-22 at 17:59 -0700, Stephen Hemminger wrote: 
> On Wed, 20 Jun 2012 17:06:32 -0700
> "Michael Chan" <mchan@broadcom.com> wrote:
> 
> > Some tg3 devices have management firmware that can export data such as
> > temperature and other real time diagnostics data.  Export this data to
> > sysfs so that userspace can access this information.
> > 
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Linux has existing sensor api's that can be used by existing
> services like SNMP. Wouldn't you like the it to just work with
> existing code API's?
> 

Is it the lm-sensors API?  The data that we are exporting is for the
Lights out management for the system OEMs.  I need to check with the
OEM.
