From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_tbf: report backlog information
Date: Thu, 29 Dec 2011 15:07:31 -0500 (EST)
Message-ID: <20111229.150731.37711012523704595.davem@davemloft.net>
References: <1325150864.2607.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063Ab1L2UHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 15:07:36 -0500
In-Reply-To: <1325150864.2607.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Dec 2011 10:27:44 +0100

> Provide child qdisc backlog (byte count) information so that "tc -s
> qdisc" can report it to user.
> 
> qdisc netem 30: root refcnt 18 limit 1000 delay 20.0ms  10.0ms
>  Sent 948517 bytes 898 pkt (dropped 0, overlimits 0 requeues 1) 
>  rate 175056bit 16pps backlog 114b 1p requeues 1 
> qdisc tbf 40: parent 30: rate 256000bit burst 20Kb/8 mpu 0b lat 0us 
>  Sent 948517 bytes 898 pkt (dropped 15, overlimits 611 requeues 0) 
>  backlog 18168b 12p requeues 0 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
