From: Chris Wright <chrisw@sous-sol.org>
Subject: igb VF allocation with quirk_i82576_sriov
Date: Mon, 21 Sep 2009 22:19:10 -0700
Message-ID: <20090922051910.GC1035@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: John Ronciak <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:45460 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754004AbZIVFTU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2009 01:19:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is this known to work?  During recent virt testing for upcoming Fedora 12,
a box w/out SR-IOV support in BIOS was using quirk to create VF BAR space,
VF allocation worked enough to assign a device to the guest, but igbvf
was not actually functioning properly in the guest.

Is it worth debugging this further, or is it already a known issue?

thanks,
-chris
