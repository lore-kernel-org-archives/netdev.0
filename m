From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] ipv6: clean up dev_snmp6 proc entry when we
 fail to initialize inet6_dev
Date: Wed, 04 Nov 2015 23:56:32 -0500 (EST)
Message-ID: <20151104.235632.744952191731338440.davem@davemloft.net>
References: <94ceff1a1f708ce80664370c783f7bfb066fccb5.1446577025.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, dvyukov@google.com,
	hannes@stressinduktion.org, cwang@twopensource.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965163AbbKEE7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 23:59:23 -0500
In-Reply-To: <94ceff1a1f708ce80664370c783f7bfb066fccb5.1446577025.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Wed,  4 Nov 2015 18:00:13 +0100

> In ipv6_add_dev, when addrconf_sysctl_register fails, we do not clean up
> the dev_snmp6 entry that we have already registered for this device.
> Call snmp6_unregister_dev in this case.
> 
> Fixes: a317a2f19da7d ("ipv6: fail early when creating netdev named all or default")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied, thanks.
