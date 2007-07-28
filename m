From: Gabriel C <nix.or.die@googlemail.com>
Subject: NETPOLL=y , NETDEVICES=n compile error ( Re: 2.6.23-rc1-mm1 )
Date: Sat, 28 Jul 2007 17:44:45 +0200
Message-ID: <46AB646D.8020104@googlemail.com>
References: <20070725040304.111550f4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jason.wessel@windriver.com, amitkale@linsyssoft.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:47045 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbXG1Psu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2007 11:48:50 -0400
Received: by ug-out-1314.google.com with SMTP id j3so843500ugf
        for <netdev@vger.kernel.org>; Sat, 28 Jul 2007 08:48:49 -0700 (PDT)
In-Reply-To: <20070725040304.111550f4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I got this compile error with a randconfig ( http://194.231.229.228/MM/randconfig-auto-82.broken.netpoll.c ).

...

net/core/netpoll.c: In function 'netpoll_poll':
net/core/netpoll.c:155: error: 'struct net_device' has no member named 'poll_controller'
net/core/netpoll.c:159: error: 'struct net_device' has no member named 'poll_controller'
net/core/netpoll.c: In function 'netpoll_setup':
net/core/netpoll.c:670: error: 'struct net_device' has no member named 'poll_controller'
make[2]: *** [net/core/netpoll.o] Error 1
make[1]: *** [net/core] Error 2
make: *** [net] Error 2
make: *** Waiting for unfinished jobs....

...


I think is because KGDBOE selects just NETPOLL.


Regards,

Gabriel
