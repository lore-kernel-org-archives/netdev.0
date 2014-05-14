From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/5] ixgbe: increase default TX ring buffer to
 1024
Date: Wed, 14 May 2014 13:49:50 -0400 (EDT)
Message-ID: <20140514.134950.1208688313542719676.davem@davemloft.net>
References: <20140514141545.20309.28343.stgit@dragon>
	<20140514141748.20309.83121.stgit@dragon>
	<537399C2.8070908@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, dborkman@redhat.com, fw@strlen.de,
	shemminger@vyatta.com, paulmck@linux.vnet.ibm.com,
	robert@herjulf.se, greearb@candelatech.com,
	john.r.fastabend@intel.com, danieltt@kth.se, zhouzhouyi@gmail.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbaENRtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 13:49:53 -0400
In-Reply-To: <537399C2.8070908@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 14 May 2014 09:28:50 -0700

> I'd say that it might be better to just add a note to the documentation
> folder indicating what configuration is optimal for pktgen rather then
> changing everyone's defaults to support one specific test.

We could have drivers provide a pktgen config adjustment mechanism,
so if someone starts pktgen then the device auto-adjusts to a pktgen
optimal configuration (whatever that may entail).
