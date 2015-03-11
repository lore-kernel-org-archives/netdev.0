From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] dsa: change "select" to "depends on" for
 switchdev in Kconfig
Date: Wed, 11 Mar 2015 18:04:59 -0400 (EDT)
Message-ID: <20150311.180459.1988980831203507955.davem@davemloft.net>
References: <1426092268-1713-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, sfeldma@gmail.com,
	rdunlap@infradead.org, alexei.starovoitov@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbbCKWFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 18:05:01 -0400
In-Reply-To: <1426092268-1713-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 11 Mar 2015 17:44:28 +0100

> This would fix randconfig compile error:
> net/built-in.o: In function `netdev_switch_fib_ipv4_abort':
> (.text+0xf7811): undefined reference to `fib_flush_external'
> 
> Also it fixes following warning:
> warning: (NET_DSA) selects NET_SWITCHDEV which has unmet direct dependencies (NET && INET)
> 
> Suggested-by: Randy Dunlap <rdunlap@infradead.org>
> Suggested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

This is a huge mess.

As Randy stated, lots of stuff does select DSA still.

I think all references to switchdev and dsa need to be converted
to depends, in order to really fix this problem properly.

Thanks.
