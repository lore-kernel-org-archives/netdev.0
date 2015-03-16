From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] dsa: change "select" to "depends on" for
 NET_SWITCHDEV and for NET_DSA
Date: Mon, 16 Mar 2015 16:31:13 -0400 (EDT)
Message-ID: <20150316.163113.1481259045405592179.davem@davemloft.net>
References: <1426505612-2144-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, sfeldma@gmail.com,
	rdunlap@infradead.org, alexei.starovoitov@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37708 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933293AbbCPUbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 16:31:17 -0400
In-Reply-To: <1426505612-2144-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 16 Mar 2015 12:33:32 +0100

> This would fix randconfig compile error:
> net/built-in.o: In function `netdev_switch_fib_ipv4_abort':
> (.text+0xf7811): undefined reference to `fib_flush_external'
> 
> Also it fixes following warnings:
> warning: (NET_DSA) selects NET_SWITCHDEV which has unmet direct dependencies (NET && INET)
> 
> warning: (NET_DSA_MV88E6060 && NET_DSA_MV88E6131 && NET_DSA_MV88E6123_61_65 && NET_DSA_MV88E6171 && NET_DSA_MV88E6352 && NET_DSA_BCM_SF2) selects NET_DSA which has unmet direct dependencies (NET && HAVE_NET_DSA && NET_SWITCHDEV)
> 
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Suggested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks.
