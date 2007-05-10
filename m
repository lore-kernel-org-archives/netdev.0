From: Zhu Yi <yi.zhu@intel.com>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Thu, 10 May 2007 11:02:20 +0800
Message-ID: <1178766140.3045.24.camel@debian.sh.intel.com>
References: <D5C1322C3E673F459512FB59E0DDC32902CDF558@orsmsx414.amr.corp.intel.com>
	 <1178666902.4055.28.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com, cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54354 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752844AbXEJDCU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 23:02:20 -0400
In-Reply-To: <1178666902.4055.28.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-05-08 at 19:28 -0400, jamal wrote:
> Wireless with CSMA/CA is a slightly different beast due to the shared
> channels; its worse but not very different in nature than the case
> where you have a shared ethernet hub (CSMA/CD) and you keep adding
> hosts to it 

The difference is the hub provides the same transmission chance for all
the packets but in wireless, high priority packets will block low
priority packets transmission. You can argue there is still chances a
low priority packet is sent first before a high priority one. But this
is not the point of wireless QoS. It rarely happens and should be avoid
at best effort in the implementation.

Thanks,
-yi
