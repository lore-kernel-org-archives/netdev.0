From: Simon Horman <horms@verge.net.au>
Subject: igb/igbvf: Bandwidth Allocation
Date: Fri, 28 Aug 2009 12:28:39 +1000
Message-ID: <20090828022825.GD6724@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:50787 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbZH1C2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 22:28:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am wondering if there is any work being done on implementing
Bandwidth Allocation in the igb driver. By which I mean
using the VMBACS, VMBAMMW, VMBASEL and VMBAC registers
as per section 4.5.11.1.5 "Allocation of Tx Bandwidth to VM"
in the "Intel 82576 Gigabit Ethernet Controller Datasheet" v2p41.

