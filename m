From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: kernel softlockup/networking/e1000
Date: Tue, 18 Dec 2007 10:23:30 -0800
Message-ID: <47681022.60500@intel.com>
References: <20071218130531.M27756@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33379 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762119AbXLRSYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 13:24:11 -0500
In-Reply-To: <20071218130531.M27756@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> At the beginning - kernel is with "gentoo patched", but i checked, there is 
> nothing major and almost none from patched code used on this router (there is 
> almost no networking patches, except e1000e support, small GRE fix and few 
> wireless things, which is not used).
> 
> syslog
> http://www.nuclearcat.com/kern.log


Looks like you're hitting an old bug where there is a race between something
running in the background continuously hitting ethtool ioctls and the driver's
watchdog.

Can you identify which program is doing the ethtool command? That would help.

Please re-test with the latest git tree  - I believe that we just recently fixed
this bug, and I'm almost sure that your kernel does not have that fix.

Cheers,

Auke
