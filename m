From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH RESEND] 3 ixgb fixes, please pull
Date: Sat, 06 Jan 2007 10:06:41 -0800
Message-ID: <459FE531.2080604@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:6731 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751443AbXAFSGo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Jan 2007 13:06:44 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,


These 3 patches were earlier submitted and ACKed by Jeff Garzik on 12/08, 12/11. They 
were part of a larger submission that also included e1000 patches. The ixgb patches 
still need to be merged. The spurious NETIF_F_TSO flags were removed from patch "Fix 
early TSO completion" as requested.

These patches apply against netdev-2.6 #upstream-fixes commit
81f4e6c190a0fa016fd7eecaf76a5f95d121afc2. Please pull:

git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-fixes

to receive them.

Cheers,

Auke

see also:

http://marc.theaimsgroup.com/?l=linux-netdev&m=116584793808733&w=2
http://marc.theaimsgroup.com/?l=linux-netdev&m=116584793729158&w=2
http://marc.theaimsgroup.com/?l=linux-netdev&m=116593164226253&w=2

---
Jesse Brandeburg <jesse.brandeburg@intel.com>
     ixgb: Fix early TSO completion
     ixgb: Maybe stop TX if not enough free descriptors

Aaron Salter <aaron.k.salter@intel.com>
     ixgb: Write RA register high word first, increment version


---
  drivers/net/ixgb/ixgb.h         |    1
  drivers/net/ixgb/ixgb_ethtool.c |    1
  drivers/net/ixgb/ixgb_hw.c      |    3 +-
  drivers/net/ixgb/ixgb_main.c    |   60 ++++++++++++++++++++++++++++++++++++----
  4 files changed, 58 insertions(+), 7 deletions(-)


---
Auke Kok <auke-jan.h.kok@intel.com>
-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
