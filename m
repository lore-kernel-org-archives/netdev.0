From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: BCM5709 hang and state dump...
Date: Thu, 7 Mar 2013 03:00:30 -0800
Message-ID: <1362654030.8980.62.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <5125B01E.4090405@numascale-asia.com>
 <1361483951.2240.44.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <5126D912.9000800@numascale-asia.com>
 <51386B82.5050900@numascale-asia.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Steffen Persvold" <sp@numascale.com>, netdev@vger.kernel.org
To: "Daniel J Blueman" <daniel@numascale-asia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3491 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754610Ab3CGLBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 06:01:18 -0500
In-Reply-To: <51386B82.5050900@numascale-asia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-07 at 18:27 +0800, Daniel J Blueman wrote: 
> We've hit this again [1], with 3.8.0 this time. Any success on the debug 
> patches?

I have 2 suggestions at this point:

1. Some users who report similar issues say that upgrading the BIOS has
fixed the issue.  So please try upgarding the BIOS if possible.

2. You can also disable MSIX and see if it runs any better.  Use sysfs
to do that or simply use bnx2 parameter disable_msi=1.

I suspect that some MSIX IRQ messages are not delivered to the CPU for
some reason.  Please try one or both suggestions and let me know.

Thanks.
> 
> 
