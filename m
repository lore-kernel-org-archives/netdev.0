From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make TLLAO option for NA packets configurable
Date: Wed, 07 Oct 2009 01:29:46 -0700 (PDT)
Message-ID: <20091007.012946.80230952.davem@davemloft.net>
References: <200910020119.47320.opurdila@ixiacom.com>
	<20091002105351.0fbde9c2@nehalam>
	<200910030039.15952.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, cratiu@ixiacom.com, netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46098
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933695AbZJGI3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 04:29:50 -0400
In-Reply-To: <200910030039.15952.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Sat, 3 Oct 2009 00:39:15 +0300

> Subject: [PATCH] ipv6: new sysctl for sending TLLAO with unicast NAs
> 
> Neighbor advertisements responding to unicast neighbor solicitations
> did not include the target link-layer address option. This patch adds
> a new sysctl option (disabled by default) which controls whether this
> option should be sent even with unicast NAs.
> 
> The need for this arose because certain routers expect the TLLAO in
> some situations even as a response to unicast NS packets.
> 
> Moreover, RFC 2461 recommends sending this to avoid a race condition
> (section 4.4, Target link-layer address)
> 
> Signed-off-by: Cosmin Ratiu <cratiu@ixiacom.com>
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

Applied, thanks!
