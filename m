From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: test MSI interrupts
Date: Thu, 27 Mar 2008 14:59:59 -0700 (PDT)
Message-ID: <20080327.145959.64040869.davem@davemloft.net>
References: <47EA9911.8040101@garzik.org>
	<47EAB54A.1060306@intel.com>
	<36D9DB17C6DE9E40B059440DB8D95F5204BF07F7@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, jeff@garzik.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55710
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756482AbYC0V77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 17:59:59 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5204BF07F7@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Thu, 27 Mar 2008 10:53:43 -0700

> >> The platforms with MSI problems should be discovered, made public,
> >> and worked around. 
> 
> This is our workaround, it is our fault, the incompatible chipset is in
> an x3850 IBM system.

Then you look for that system chipset variant in the e1000e driver and
not use MSI when it is found.

A generic test really is not warranted.
