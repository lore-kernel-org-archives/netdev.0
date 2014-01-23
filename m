From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH stable 3.7+] fib_frontend: fix possible NULL pointer
 dereference
Date: Thu, 23 Jan 2014 04:26:33 -0800
Message-ID: <1390479993.27806.49.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52E0DEA6.3060803@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:64965 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbaAWM0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 07:26:34 -0500
Received: by mail-pd0-f170.google.com with SMTP id p10so1723668pdj.29
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 04:26:34 -0800 (PST)
In-Reply-To: <52E0DEA6.3060803@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-23 at 10:19 +0100, Oliver Hartkopp wrote:
> The two commits 0115e8e30d (net: remove delay at device dismantle) and
> 748e2d9396a (net: reinstate rtnl in call_netdevice_notifiers()) silently
> removed a NULL pointer check for in_dev since Linux 3.7.
> 
> This patch re-introduces this check as it causes crashing the kernel when
> setting small mtu values on non-ip capable netdevices.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> 
> ---

Thanks for the fix !

Acked-by: Eric Dumazet <edumazet@google.com>
