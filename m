From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inetdevice.h must include sysctl.h
Date: Fri, 22 Jun 2007 17:04:44 -0700 (PDT)
Message-ID: <20070622.170444.92252701.davem@davemloft.net>
References: <a781481a0706221656h24814729qf25b1319db14b55@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ysato@users.sourceforge.jp, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: satyam.sharma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55889
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751269AbXFWAEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 20:04:25 -0400
In-Reply-To: <a781481a0706221656h24814729qf25b1319db14b55@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Satyam Sharma" <satyam.sharma@gmail.com>
Date: Sat, 23 Jun 2007 05:26:52 +0530

> [PATCH] include sysctl.h from inetdevice.h
> 
> When CONFIG_INET=y and CONFIG_SYSCTL=n:
> 
> In file included from net/core/netpoll.c:16:
> include/linux/inetdevice.h:15: error:
> '__NET_IPV4_CONF_MAX' undeclared here (not in a function)
> make[2]: *** [net/core/netpoll.o] Error 1
> make[1]: *** [net/core] Error 2
> make: *** [net] Error 2
> 
> So #include sysctl.h from inetdevice.h.
> 
> Signed-off-by: Satyam Sharma <satyam.sharma@gmail.com>

Patch applied, thank you.
