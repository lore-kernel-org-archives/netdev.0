From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next 0/2] igb: fixes and improvements for irq fallback
Date: Mon,  3 Dec 2012 14:14:59 +0100
Message-ID: <1354540501-18407-1-git-send-email-sassmann@kpanic.de>
Cc: e1000-devel@lists.sourceforge.net, alexander.h.duyck@intel.com,
	carolyn.wyborny@intel.com, jeffrey.t.kirsher@intel.com,
	sassmann@kpanic.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49448 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733Ab2LCNQN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2012 08:16:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupt fallback code should utilize the same code that's used for normal
setup instead of duplicating it. It also has some shortcomings when it comes
to situations where for some reason request_irq() fails to allocate vectors for
MSI-X. Hoping to address these with this patchset.

Would be nice for these patches to go through Intel testing before inclusion.

Stefan Assmann (2):
  igb: remove duplicate code for fallback interrupt initialization
  igb: release already assigned MSI-X interrupts if setup fails

-- 
1.7.11.7
