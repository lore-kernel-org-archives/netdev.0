From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: SO_TIMESTAMPING fix and design decisions
Date: Sat, 19 Sep 2009 15:09:21 -0700
Message-ID: <1253398161.14869.2.camel@localhost.localdomain>
References: <20090919192549.0735c93a@pundit>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christopher Zimmermann <madroach@zakweb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10631 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750954AbZISWKC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Sep 2009 18:10:02 -0400
In-Reply-To: <20090919192549.0735c93a@pundit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-09-19 at 10:25 -0700, Christopher Zimmermann wrote:
> Hi, 
> 
> I'm currently working on the SO_TIMESTAMPING feature which is currently 
> pretty much broken. The current status is the following:
> 
> -tx software timestamps don't work because of a race condition. See 
> commit cd4d8fdad1f1320.
> -rx software timestamps do work. But they are nothing new.
> SO_TIMESTAMP[NS] has been available for years.
> 
> hardware timestamps only work for the Intel igb driver. I have access to 
> two test machines with NICs supported by this driver.
> 

Intel's 82599, supported by ixgbe, also has the same IEEE 1588
timestamping support in hardware.  We haven't implemented the support
yet in ixgbe, but the hardware is there and does work.  If you were
curious of the interface, the datasheet for the hardware is available on
our SourceForge site (e1000.sf.net).

Cheers,
-PJ

