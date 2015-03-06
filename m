From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: wireless-drivers-next 2015-03-06
Date: Fri, 06 Mar 2015 15:46:39 -0500 (EST)
Message-ID: <20150306.154639.1922888192237476633.davem@davemloft.net>
References: <874mpy2gw5.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56098 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbbCFUqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 15:46:42 -0500
In-Reply-To: <874mpy2gw5.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalle Valo <kvalo@codeaurora.org>
Date: Fri, 06 Mar 2015 19:08:10 +0200

> here's a pull request for net-next. Lots of smaller fixes and cleanup,
> major changes are documented in the signed tag and available below
> 
> Do note that I wasn't able compile net-next (commit 23375a0fd549) with
> my config:
> 
> wireless-drivers-next/include/net/switchdev.h:133: multiple definition of `netdev_switch_fib_ipv4_abort'
> net/bridge/br.o:wireless-drivers-next/include/net/switchdev.h:133: first defined here
> net/bridge/br_netlink.o: In function `netdev_switch_fib_ipv4_abort':
> wireless-drivers-next/include/net/switchdev.h:133: multiple definition of `netdev_switch_fib_ipv4_abort'
> net/bridge/br.o:wireless-drivers-next/include/net/switchdev.h:133: first defined here
> 
> But this pull request should still merge to net-next without conflicts.

Yeah I just applied a fix for that.

> Please let me know if you have any problems.

Pulled, thanks.
