From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: RE: When TCP keepalives tuned shorter than retransmission timeouts
Date: Wed, 4 Dec 2013 13:50:58 -0800 (PST)
Message-ID: <47086954-fccc-425a-8548-e3c88df93ee7@default>
References: <4b6029b3-55da-441a-9550-0fed3b49506a@default>
 <1385482822.5352.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23954 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755795Ab3LDVvB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 16:51:01 -0500
In-Reply-To: <1385482822.5352.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Then change max number of retransmits : tcp_retries2 ?
> 
> Keepalive timer is not a way to defeat TCP exponential backoff.
> 
> Its really there to send probes when a session is idle.
> 

Thanks. We plan to try out TCP_USER_TIMEOUT option since that is settable per-socket.

Venkat
