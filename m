From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6] XFRM: Fix auditing rt6i_flags; use RTF_xxx
 flags instead of RTCF_xxx.
Date: Fri, 07 Dec 2007 23:51:35 -0800 (PST)
Message-ID: <20071207.235135.81440123.davem@davemloft.net>
References: <20071207.104148.112502523.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38244
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750790AbXLHHvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 02:51:36 -0500
In-Reply-To: <20071207.104148.112502523.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Fri, 07 Dec 2007 10:41:48 -0800 (PST)

> RTCF_xxx flags, defined in include/linux/in_route.h) are available for
> IPv4 route (rtable) entries only.  Use RTF_xxx flags instead,
> defined in include/linux/ipv6_route.h, for IPv6 route entries (rt6_info).
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thank you.
