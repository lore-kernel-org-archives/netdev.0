From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] IPv6:Remove options header when setsockopt's
 optlen is 0
Date: Thu, 19 Jun 2008 16:30:26 -0700 (PDT)
Message-ID: <20080619.163026.163287819.davem@davemloft.net>
References: <4858AE3D.6070101@cn.fujitsu.com>
	<20080619.165218.40446264.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40759
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754145AbYFSXa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 19:30:26 -0400
In-Reply-To: <20080619.165218.40446264.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 19 Jun 2008 16:52:18 +0900 (JST)

> In article <4858AE3D.6070101@cn.fujitsu.com> (at Wed, 18 Jun 2008 14:42:05 +0800), Shan Wei <shanwei@cn.fujitsu.com> says:
> 
> > Remove the sticky Hop-by-Hop options header by calling setsockopt() for IPV6_HOPOPTS
> > with a zero option length, per RFC3542.
> > 
> > Routing header and Destination options header does the same as Hop-by-Hop options header. 
> > 
> > 
> > Signed-off-by: Shan Wei<shanwei@cn.fujitsu.com>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6, thanks!
