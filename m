From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 25/44] [IPV6] MIP6: Add inbound interface of home
 address option.
Date: Wed, 23 Aug 2006 19:26:35 -0700 (PDT)
Message-ID: <20060823.192635.52168955.davem@davemloft.net>
References: <1156345366549-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453662956-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453661764-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19673
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030208AbWHXC0d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 22:26:33 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453661764-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:26 +0900

> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> Add inbound function of home address option by registering it to TLV table for
> destination options header.
> Based on MIPL2 kernel patch.
> 
> This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thank you.

I made a small change afterwards, placing 'dsthao' after
'flags' in inet6_skb_parm in order to pack structure more
tightly.

Thanks again.
