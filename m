From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 4/4] e1000e: Allow TSO to trickle down to VLAN device
Date: Mon, 19 May 2008 16:03:54 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329051AC441@orsmsx414.amr.corp.intel.com>
References: <20080519224303.7175.71980.stgit@localhost.localdomain> <20080519224652.7175.74105.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	<jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53429 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755157AbYESXDz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 19:03:55 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080519224652.7175.74105.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Fix TSO over VLAN's by propagating settings to our VLAN devices.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/ethtool.c |   16 ++++++++++++++++
>  drivers/net/e1000e/netdev.c  |    8 ++++++++
>  2 files changed, 24 insertions(+), 0 deletions(-)

I think this one got accidentally pushed.  I'm still working on a fix
for this based on Patrick's request to not directly mess with the VLAN
flags.

Jeff K and Jeff G, please hold off on this patch.  I'll work with Jeff
K. on getting this the proper fix.  This is my fault that it's written
this way in these drivers, and I'll get it corrected.

Thanks,

-PJ Waskiewicz
<peter.p.waskiewicz.jr@intel.com>
