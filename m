From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 0/2] atl1: Introduce CONFIG_ATL1_EXPERIMENTAL
Date: Fri, 07 Sep 2007 19:41:32 -0400
Message-ID: <46E1E1AC.5030801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: atl1-devel@lists.sourceforge.net,
	Jay Cliburn <jacliburn@bellsouth.net>,
	Chris Snook <csnook@redhat.com>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50155 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751323AbXIGXlp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 19:41:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The atl1 driver is currently marked EXPERIMENTAL, because a few supposedly 
performance-enhancing features still have problems.  When these features are 
disabled, the driver is completely stable, fully functional, and performs well.

Patch 1/2 Creates the kconfig option CONFIG_ATL1_EXPERIMENTAL, and removes the 
EXPERIMENTAL designation from CONFIG_ATL1

Patch 2/2 Wraps some currently-disabled features in #ifdef 
CONFIG_ATL1_EXPERIMENTAL, so developers and testers can play with these features 
more easily, and distributions will still get a fast, stable driver with 
existing .config files.

We'll also be using this to wrap around various new features we'll be 
experimenting with in coming months.  Instead of using a half dozen different 
kconfig options for each of them, like some drivers do, we'll just use this, and 
make sure things are safe for everyone before we take them out of the 
experimental wrapper.

	-- Chris
