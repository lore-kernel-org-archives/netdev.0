From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: Re: 3.4.1 and 3.5-rc1 Packet lost at 250Mb/s
Date: Mon, 08 Oct 2012 11:29:45 +0200
Message-ID: <9819d6943a7cfddfc8fa49217aa4842e@justnet.pl>
References: <409ac8b30a6994028562e1a159ac60aa@justnet.pl>
 <1349677373.21172.2756.camel@edumazet-glaptop>
Reply-To: <adam.niescierowicz@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-91.230.163.37.ltv.pl ([91.230.163.37]:59104 "EHLO
	mail.justnet.pl" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750709Ab2JHJ3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 05:29:55 -0400
In-Reply-To: <1349677373.21172.2756.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> You should use RPS on eth2/eth3 because they are non multi queue.
>
> Documentation/networking/scaling.txt should give you all the needed 
> info

I set processors for rps such as affinity, unfortunately it did not 
help

---
cat /sys/class/net/eth{2,3,4,5}/queues/rx-0/rps_cpus
0040
0080
0100
0200
---
CPU affinity http://wklej.org/id/843161/
