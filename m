From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Thu, 24 Jul 2008 16:18:59 -0700 (PDT)
Message-ID: <20080724.161859.193696763.davem@davemloft.net>
References: <200807250112.03379.opurdila@ixiacom.com>
	<20080724.151733.215864673.davem@davemloft.net>
	<200807250214.11298.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55975
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755505AbYGXXS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 19:18:59 -0400
In-Reply-To: <200807250214.11298.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Fri, 25 Jul 2008 02:14:11 +0300

> Sure but the problem is that the NIC hw timestamp is not synced with
> the CPU time. In that case I think that the netfilter rules which
> are looking at the timestamp will be messed up.

Right, but you can maintain a suitable "delta" between the two.
