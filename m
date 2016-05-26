From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 4/4] net/mlx4_en: get rid of private
 net_device_stats
Date: Thu, 26 May 2016 12:38:49 -0700 (PDT)
Message-ID: <20160526.123849.1592401154314458544.davem@davemloft.net>
References: <1464195039-5098-5-git-send-email-edumazet@google.com>
	<6320ccdc-d369-c08c-c959-6c8ed9b88d10@gmail.com>
	<1464267250.5939.78.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ttoukan.linux@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, willemb@google.com, eugenia@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754883AbcEZTiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 15:38:51 -0400
In-Reply-To: <1464267250.5939.78.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 May 2016 05:54:10 -0700

> These stats being computed using deltas, this can not work as is.
> 
> I believe the rule is to not clear the netdev stats at open()

+1

Any driver clearing stats at open is broken and will break many,
many, networking tools.  And bonding too.
