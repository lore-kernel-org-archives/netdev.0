From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] tcp: change tcp_adv_win_scale and tcp_rmem[2]
Date: Wed, 02 May 2012 14:05:52 -0700
Message-ID: <4FA1A1B0.3060407@hp.com>
References: <1335961721.22133.562.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Neal Cardwell <ncardwell@google.com>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:1469 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299Ab2EBVFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 17:05:55 -0400
In-Reply-To: <1335961721.22133.562.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2012 05:28 AM, Eric Dumazet wrote:
> We should adjust the len/truesize ratio to 50% instead of 75%

As an added bonus, it would be consistent with the code behind 
setsockopt(SO_[SND|RCV]BUF) doubling what the user passes-in. (modulo 
the net.core.[rw]mem_max setting)

rick jones
