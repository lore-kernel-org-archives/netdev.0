From: Simon Horman <horms@verge.net.au>
Subject: [rfc 0/3 v2] igb: bandwidth allocation
Date: Wed, 25 Nov 2009 17:32:13 +1100
Message-ID: <20091125063213.203372240@vergenet.net>
Cc: Arnd Bergmann <arndbergmann@googlemail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:47782 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751841AbZKYGgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 01:36:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this series of patches exposes the bandwidth allocation hardware support of
the Intel 82576. It does so through a rather hackish sysfs entry. That
interface is just intended for testing so that the exposed hardware feature
can be exercised. I would like to find a generic way to expose this feature
to user-space.

v2 of the removes patch "Initialise adapter->vfs_allocated_count in
igb_init_vf()" as it causes a panic.

