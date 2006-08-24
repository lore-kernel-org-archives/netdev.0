From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 23/44] [IPV6]: Allow to replace skbuff by TLV parser.
Date: Wed, 23 Aug 2006 19:20:09 -0700 (PDT)
Message-ID: <20060823.192009.35356948.davem@davemloft.net>
References: <11563453662913-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453663400-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345366549-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:65252
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030204AbWHXCUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 22:20:07 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <1156345366549-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:24 +0900

> In receiving Mobile IPv6 home address option which is a TLV carried
> by destination options header, kernel will try to mangle source adderss
> of packet. Think of cloned skbuff it is required to replace it by
> the parser just like routing header case.
> This is a framework to achieve that to allow TLV parser to replace
> inbound skbuff pointer.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks a lot.
