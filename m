From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: fix multiple inclusion of vxlan.h
Date: Tue, 25 Aug 2015 14:32:26 -0700 (PDT)
Message-ID: <20150825.143226.1387694042048934503.davem@davemloft.net>
References: <27e0c4c1aec49f461ba96fac8c40f69b46ef06dd.1440520548.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mark.d.rustad@intel.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbbHYVc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 17:32:27 -0400
In-Reply-To: <27e0c4c1aec49f461ba96fac8c40f69b46ef06dd.1440520548.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue, 25 Aug 2015 18:36:50 +0200

> The vxlan_get_sk_family inline function was added after the last #endif,
> making multiple inclusion of net/vxlan.h fail. Move it to the proper place.
> 
> Reported-by: Mark Rustad <mark.d.rustad@intel.com>
> Fixes: 705cc62f6728c ("vxlan: provide access function for vxlan socket address family")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied, thanks.
