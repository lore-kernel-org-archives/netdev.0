From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6] MIP6: Fix to update IP6CB when cloned skbuff is
 received at HAO.
Date: Thu, 31 Aug 2006 15:20:47 -0700 (PDT)
Message-ID: <20060831.152047.35450868.davem@davemloft.net>
References: <1156345366549-git-send-email-yoshfuji@linux-ipv6.org>
	<20060823.192009.35356948.davem@davemloft.net>
	<200608312105.41650.nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6376
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964802AbWHaWUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 18:20:42 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <200608312105.41650.nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Thu, 31 Aug 2006 21:05:41 +0900

> > From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> > Date: Thu, 24 Aug 2006 00:02:24 +0900
> > 
> > > In receiving Mobile IPv6 home address option which is a TLV carried
> > > by destination options header, kernel will try to mangle source adderss
> > > of packet. Think of cloned skbuff it is required to replace it by
> > > the parser just like routing header case.
> > > This is a framework to achieve that to allow TLV parser to replace
> > > inbound skbuff pointer.
> > > 
> > > Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> > > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> > 
> > Applied to net-2.6.19, thanks a lot.
> > 
> 
> I've found issue about the patch above.
> This is a fix for it, to update IP6CB when cloned skbuff is received at HAO.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Patch applied, thank you very much.
