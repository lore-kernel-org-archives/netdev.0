From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/9] PCI vpd patches (rev4)
Date: Thu, 25 Sep 2008 09:48:51 -0700
Message-ID: <20080925164851.694359776@vyatta.com>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Ivan Vecera <ivecera@redhat.com>
To: Jeff Garzik <jgarzik@pobox.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59990 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753781AbYIYRCH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 13:02:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is update to VPD access patches.  These fix the VPD routines
to have a sufficient timeout, and modify the skge/sky2 drivers to
not use their own VPD access code.

Since only network drivers are impacted, these should go through
the net-next tree for 2.6.28.

-- 

