From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] [IPV4]: Use Protocol Independant Policy Routing
 Rules Framework
Date: Wed, 26 Jul 2006 16:47:00 -0700 (PDT)
Message-ID: <20060726.164700.34544679.davem@davemloft.net>
References: <20060726221100.325687073@postel.suug.ch>
	<20060726221850.460778279@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48086
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751747AbWGZXqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 19:46:45 -0400
To: tgraf@suug.ch
In-Reply-To: <20060726221850.460778279@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 27 Jul 2006 00:00:05 +0200

> Index: net-2.6.git/net/ipv4/fib_rules.c
> ===================================================================
> --- net-2.6.git.orig/net/ipv4/fib_rules.c
> +++ net-2.6.git/net/ipv4/fib_rules.c
 ...
> -	new_r = kmalloc(sizeof(*new_r), GFP_KERNEL);
> -	if (!new_r)
> -		return -ENOMEM;
> -	memset(new_r, 0, sizeof(*new_r));

When you respin these patches, please regenerate them against
the current tree which now uses kzalloc() here.

Thanks.
