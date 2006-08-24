From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 36/44] [XFRM]: Introduce XFRM_MSG_REPORT.
Date: Wed, 23 Aug 2006 20:43:52 -0700 (PDT)
Message-ID: <20060823.204352.123974654.davem@davemloft.net>
References: <1156345367208-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453673786-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453672531-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14234
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030264AbWHXDnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:43:50 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453672531-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:37 +0900

> XFRM_MSG_REPORT is a message as notification of state protocol and selector
> from kernel to user-space.
> Mobile IPv6 will use it when inbound reject is occurred at route optimization
> to make user-space know a binding error requirement.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, but...

Please check whether this XFRM_MSG_REPORT functionality can be
provided via XFRM_MSG_*AE.  It seems to me that AEVENTS can be
used to report these rejection situations too.  But you might
have a good reason why not do merge the functionality.

Just let me know.
