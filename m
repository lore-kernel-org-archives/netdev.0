From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/3] e1000: fix shared interrupt warning message
Date: Sun, 18 Feb 2007 00:19:49 +0100
Message-ID: <20070217231949.GB17396@electric-eye.fr.zoreil.com>
References: <20070216223913.26963.76602.stgit@gitlost.site> <20070216223926.26963.52634.stgit@gitlost.site> <45D767C8.3040508@garzik.org> <45D769FD.4030508@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36355 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964910AbXBQXWP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 18:22:15 -0500
Content-Disposition: inline
In-Reply-To: <45D769FD.4030508@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok <auke-jan.h.kok@intel.com> :
[...]
> It is suspected that workarounds in the _up() routine of e1000 can cause 
        ^^^^^^^^^
> the receive unit to be enabled before we're all done initializing the 
> adapter data. An interrupt arriving before we're all done setting up 
> obviously causes problems. To fix, we postpone enabling interrupts 
> completely until the software intialization is finished.

Call me dense but is there a chance that the same receive unit that should
not be enabled now emits interrupts between e1000_up() and request_irq() ?

-- 
Ueimor
