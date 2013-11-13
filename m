From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCH v2] tcp: tsq: restore minimal amount of queueing
Date: Wed, 13 Nov 2013 22:18:12 +0100
Message-ID: <8738n0ngq3.fsf@natisbad.org>
References: <8761s0cqhh.fsf@natisbad.org>
	<slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
	<87y54u59zq.fsf@natisbad.org>
	<1384267141.28458.24.camel@edumazet-glaptop2.roam.corp.google.com>
	<1384353174.28458.110.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Sujith Manoharan <sujith@msujith.org>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb2-g21.free.fr ([212.27.42.10]:38429 "EHLO
	smtpfb2-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003Ab3KMVTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 16:19:11 -0500
Received: from smtp4-g21.free.fr (smtp4-g21.free.fr [212.27.42.4])
	by smtpfb2-g21.free.fr (Postfix) with ESMTP id 6EA75D129C8
	for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 22:19:03 +0100 (CET)
Received: from smtp.natisbad.org (unknown [81.57.185.249])
	by smtp4-g21.free.fr (Postfix) with ESMTP id 9EAC44C81E3
	for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 22:18:21 +0100 (CET)
In-Reply-To: <1384353174.28458.110.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 13 Nov 2013 06:32:54 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Eric Dumazet <eric.dumazet@gmail.com> writes:

> From: Eric Dumazet <edumazet@google.com>
>
> After commit c9eeec26e32e ("tcp: TSQ can use a dynamic limit"), several
> users reported throughput regressions, notably on mvneta and wifi
> adapters.
>
> 802.11 AMPDU requires a fair amount of queueing to be effective.
>
> This patch partially reverts the change done in tcp_write_xmit()
> so that the minimal amount is sysctl_tcp_limit_output_bytes.

I just tested the fix on current linux tree with the same setup
on which I observed the regression: it also fixes it on my side
on my RN102. Thanks for the quick fix, Eric. 

Cheers,

a+
