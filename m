From: "Miller, Darin J" <darin.j.miller@intel.com>
Subject: RE: [Intel-wired-lan] [net-next PATCH 3/3] ixgbe: Allow FDB entries
 access to more RAR filters
Date: Wed, 4 Nov 2015 18:40:22 +0000
Message-ID: <A91205FD8A6E14448BD4414C06E9C3D375211201@fmsmsx115.amr.corp.intel.com>
References: <20151022232228.24612.81341.stgit@ahduyck-vm-fedora22>
 <20151022232642.24612.46212.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: 'Alexander Duyck' <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47922 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032115AbbKDSkY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 13:40:24 -0500
In-Reply-To: <20151022232642.24612.46212.stgit@ahduyck-vm-fedora22>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Alexander Duyck
Sent: Thursday, October 22, 2015 4:27 PM
To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; Kirsher, Jeffrey T
Subject: [Intel-wired-lan] [net-next PATCH 3/3] ixgbe: Allow FDB entries access to more RAR filters

This change makes it so that we allow the PF to make use of all free RAR entries for FDB use if needed.

Previously the code limited us to 16 unicast entries, however this was shared between MACVLAN which wasn't limited and the FDB code which was.  So instead of treating the FDB code as a second class citizen I have updated it so that it has access to just as many entries as the MACVLAN filters.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Tested-by: Darin Miller <darin.j.miller@intel.com>
