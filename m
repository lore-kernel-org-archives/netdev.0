From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Thu, 02 Apr 2009 01:05:02 -0700 (PDT)
Message-ID: <20090402.010502.259136834.davem@davemloft.net>
References: <20090323223238.GB29609@wavehammer.waldi.eu.org>
	<1237850931.18617.39.camel@HP1>
	<1238608905.18617.272.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: waldi@debian.org, ben@decadent.org.uk, davem@davemloft.org,
	netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43435
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753761AbZDBIFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:05:13 -0400
In-Reply-To: <1238608905.18617.272.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 01 Apr 2009 11:01:45 -0700

> I've made some minor changes to Bastian and Ben's patch.  I've separated
> the mips firmware from the non-mips firmware, added code to fix up the
> non-mips firmware with the host CPU's page size, and other minor
> changes.  If there are no issues, I'll send the entire patch with the
> ihex files when net-next opens up.
> 
> Thanks again to Bastian and Ben.  Here's the new patch that excludes the
> firmware ihex files for review.

I think I'm even willing to apply this for 2.6.30, let me know when
the final version is ready.
