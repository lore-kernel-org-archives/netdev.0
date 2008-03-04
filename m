From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [INET]: Updates for net-2.6.26.
Date: Mon, 03 Mar 2008 23:12:19 -0800 (PST)
Message-ID: <20080303.231219.159934678.davem@davemloft.net>
References: <20080303.004449.98475557.yoshfuji@linux-ipv6.org>
	<20080303.204549.82367997.davem@davemloft.net>
	<20080304.155946.31980558.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52190
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756365AbYCDHMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:12:20 -0500
In-Reply-To: <20080304.155946.31980558.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Tue, 04 Mar 2008 15:59:46 +0900 (JST)

> In article <20080303.204549.82367997.davem@davemloft.net> (at Mon, 03 Mar 2008 20:45:49 -0800 (PST)), David Miller <davem@davemloft.net> says:
> 
> > I can't pull this in, it breaks the build in various ways:
> > 
> > drivers/net/cxgb3/l2t.c: In function 't3_l2t_update':
> > drivers/net/cxgb3/l2t.c:410: error: implicit declaration of function 'neigh_is_connected'
> > net/ipv4/udp_ipv4.c:1068: error: 'compat_udpv4_setsockopt' undeclared here (not in a function)
> > net/ipv4/udp_ipv4.c:1069: error: 'compat_udpv4_getsockopt' undeclared here (not in a function)
> 
> Oh, sorry.  I've updated / rebased them and pushed at:
>   git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6.26-inet-20080304
> 
> I hope issues have gone away...

That looks much better, pulled and pushed back out to
net-2.6.26

Thanks!
