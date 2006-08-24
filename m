From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 26/44] [IPV6] MIP6: Revert address to send ICMPv6 error.
Date: Wed, 23 Aug 2006 19:27:50 -0700 (PDT)
Message-ID: <20060823.192750.120445359.davem@davemloft.net>
References: <11563453662956-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453661764-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453663275-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20953
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030214AbWHXC1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 22:27:47 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453663275-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:27 +0900

> IPv6 source address is replaced in receiving packet
> with home address option carried by destination options header.
> To send ICMPv6 error back, original address which is received one on wire
> should be used. This function checks such header is included
> and reverts them.
> Based on MIPL2 kernel patch.
> 
> This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks a lot.
