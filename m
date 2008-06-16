From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-2.6] ipv6 sit: Avoid extra need for compat
 layer in PRL management.
Date: Mon, 16 Jun 2008 16:53:38 -0700 (PDT)
Message-ID: <20080616.165338.195341944.davem@davemloft.net>
References: <20080613.100114.97370932.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55355
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756283AbYFPXxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 19:53:37 -0400
In-Reply-To: <20080613.100114.97370932.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Fri, 13 Jun 2008 10:01:14 +0900 (JST)

> We've introduced extra need of compat layer for ip_tunnel_prl{}
> for PRL (Potential Router List) management.  Though compat_ioctl
> is still missing in ipv4/ipv6, let's make the interface more
> straight-forward and eliminate extra need for nasty compat layer
> anyway since the interface is new for 2.6.26.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

I think this is a wise change, so I will apply it to net-2.6,
thank you!
