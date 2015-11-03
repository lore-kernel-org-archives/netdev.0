From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: clean up dev_snmp6 proc entry when we fail
 to initialize inet6_dev
Date: Tue, 03 Nov 2015 13:32:56 -0500 (EST)
Message-ID: <20151103.133256.967841790562963246.davem@davemloft.net>
References: <8e1fff92148028f407177e68355100b705cf4ad1.1446573077.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, dvyukov@google.com,
	hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbbKCSc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 13:32:58 -0500
In-Reply-To: <8e1fff92148028f407177e68355100b705cf4ad1.1446573077.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue,  3 Nov 2015 19:09:09 +0100

> In ipv6_add_dev, when addrconf_sysctl_register fails, we do not clean up
> the dev_snmp6 entry that we have already registered for this device.
> 
> It is safe to call snmp6_unregister_dev unconditionally from
> in6_dev_finish_destroy, so do it.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable, thanks.
