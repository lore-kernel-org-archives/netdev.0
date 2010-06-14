From: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Subject: Re: [PATCH net-next-2.6] ipv6: RCU changes in ipv6_get_mtu() and
 ip6_dst_hoplimit()
Date: Tue, 15 Jun 2010 00:18:24 +0900
Message-ID: <4C164840.5010900@yoshifuji.org>
References: <1276526780.2478.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:33932 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754839Ab0FNPSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 11:18:36 -0400
In-Reply-To: <1276526780.2478.101.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2010/06/14 23:46), Eric Dumazet wrote:
> Use RCU to avoid atomic ops on idev refcnt in ipv6_get_mtu()
> and ip6_dst_hoplimit()
>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
