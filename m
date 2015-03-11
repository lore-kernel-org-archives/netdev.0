From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] switchdev: select INET in Kconfig
Date: Wed, 11 Mar 2015 18:00:53 -0400 (EDT)
Message-ID: <20150311.180053.942872464652130354.davem@davemloft.net>
References: <1426067352-9327-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, sfeldma@gmail.com,
	rdunlap@infradead.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbbCKWAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 18:00:54 -0400
In-Reply-To: <1426067352-9327-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 11 Mar 2015 10:49:12 +0100

> This would fix randconfig compile error:
> net/built-in.o: In function `netdev_switch_fib_ipv4_abort':
> (.text+0xf7811): undefined reference to `fib_flush_external'
> 
> Also it fixes following warning:
> warning: (NET_DSA) selects NET_SWITCHDEV which has unmet direct dependencies (NET && INET)
> 
> Suggested-by: Randy Dunlap <rdunlap@infradead.org>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

You cannot use select with INET, it selects CRYPTO* stuff and
therefore is not a leaf Kconfig node.
