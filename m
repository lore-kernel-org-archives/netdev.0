From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: inherit listener congestion control for
 passive cnx
Date: Wed, 30 Nov 2011 13:28:57 -0800
Message-ID: <4ED6A019.2040708@hp.com>
References: <20111130003112.C04FE29005FE@tardy> <1322630461.2596.61.camel@edumazet-laptop> <1322631613.2596.70.camel@edumazet-laptop> <1322650961.2403.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:36104 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493Ab1K3V3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 16:29:02 -0500
In-Reply-To: <1322650961.2403.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Rick Jones reported that TCP_CONGESTION sockopt performed on a listener
> was ignored for its children sockets : right after accept() the
> congestion control for new socket is the system default one.
>
> This seems an oversight of the initial design (quoted from Stephen)
>
> Based on prior investigation and patch from Rick.
>
> Reported-by: Rick Jones<rick.jones2@hp.com>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> CC: Stephen Hemminger<shemminger@vyatta.com>
> CC: Yuchung Cheng<ycheng@google.com>

Tested-by: Rick Jones <rick.jones2@hp.com>

Works as expected/desired with my test program, and doesn't appear to 
affect performance measurably (loopback netperf TCP_CC test on a 1 VCPU 
guest).

rick jones
