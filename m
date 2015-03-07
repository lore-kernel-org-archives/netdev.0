From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: pull-request: wireless-drivers-next 2015-03-06
Date: Sat, 07 Mar 2015 09:18:58 +0200
Message-ID: <87vbid1di5.fsf@kamboji.qca.qualcomm.com>
References: <874mpy2gw5.fsf@kamboji.qca.qualcomm.com>
	<20150306.154639.1922888192237476633.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56912 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755404AbbCGHTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 02:19:06 -0500
In-Reply-To: <20150306.154639.1922888192237476633.davem@davemloft.net> (David
	Miller's message of "Fri, 06 Mar 2015 15:46:39 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Kalle Valo <kvalo@codeaurora.org>
> Date: Fri, 06 Mar 2015 19:08:10 +0200
>
>> here's a pull request for net-next. Lots of smaller fixes and cleanup,
>> major changes are documented in the signed tag and available below
>> 
>> Do note that I wasn't able compile net-next (commit 23375a0fd549) with
>> my config:
>> 
>> wireless-drivers-next/include/net/switchdev.h:133: multiple definition of `netdev_switch_fib_ipv4_abort'
>> net/bridge/br.o:wireless-drivers-next/include/net/switchdev.h:133: first defined here
>> net/bridge/br_netlink.o: In function `netdev_switch_fib_ipv4_abort':
>> wireless-drivers-next/include/net/switchdev.h:133: multiple definition of `netdev_switch_fib_ipv4_abort'
>> net/bridge/br.o:wireless-drivers-next/include/net/switchdev.h:133: first defined here
>> 
>> But this pull request should still merge to net-next without conflicts.
>
> Yeah I just applied a fix for that.

Thanks, net-next compiles now for me.

-- 
Kalle Valo
