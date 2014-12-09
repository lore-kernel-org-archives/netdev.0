From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] tcp_cubic: add SNMP counters to track how
 effective is Hystart
Date: Tue, 09 Dec 2014 14:58:38 -0500 (EST)
Message-ID: <20141209.145838.2277992704178215634.davem@davemloft.net>
References: <1417738403.22424.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nanditad@google.com, ncardwell@google.com,
	ycheng@google.com, sangtae.ha@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38158 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbaLIT6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 14:58:40 -0500
In-Reply-To: <1417738403.22424.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Dec 2014 16:13:23 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> When deploying FQ pacing, one thing we noticed is that CUBIC Hystart
> triggers too soon.
> 
> Having SNMP counters to have an idea of how often the various Hystart
> methods trigger is useful prior to any modifications.
> 
> This patch adds SNMP counters tracking, how many time "ack train" or
> "Delay" based Hystart triggers, and cumulative sum of cwnd at the time
> Hystart decided to end SS (Slow Start)
> 
> myhost:~# nstat -a | grep Hystart
> TcpExtTCPHystartTrainDetect     9                  0.0
> TcpExtTCPHystartTrainCwnd       20650              0.0
> TcpExtTCPHystartDelayDetect     10                 0.0
> TcpExtTCPHystartDelayCwnd       360                0.0
> 
> ->
>  Train detection was triggered 9 times, and average cwnd was
>  20650/9=2294,
>  Delay detection was triggered 10 times and average cwnd was 36
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
