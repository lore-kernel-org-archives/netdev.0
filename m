From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next:master 232/235]
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:7053:6: sparse: symbol
 'bnx2x_init_searcher' was not declared. Should it be static?
Date: Thu, 8 Nov 2012 17:15:25 +0000
Message-ID: <1352394925.2771.1.camel@bwh-desktop.uk.solarflarecom.com>
References: <20121108093805.GA1891@localhost>
	 <1352390951.5555.5.camel@lb-tlvb-meravs.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	<netdev@vger.kernel.org>
To: Merav Sicron <meravs@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56576 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751810Ab2KHRPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 12:15:32 -0500
In-Reply-To: <1352390951.5555.5.camel@lb-tlvb-meravs.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-08 at 18:09 +0200, Merav Sicron wrote:
> On Thu, 2012-11-08 at 17:38 +0800, Fengguang Wu wrote:
> > Hi Merav,
> > 
> > FYI, there are new sparse warnings show up in
> 
> Thanks. Before submitting I run sparse and it didn't catch these issues,
> but apparently it didn't function well. I will submit a patch soon.
> Merav

The kernel doesn't enable byte-order type checks by default; you have to
add CHECKFLAGS=-D__CHECK_ENDIAN__ to the make command line.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
