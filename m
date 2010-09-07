From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP packet size and delivery packet decisions
Date: Tue, 07 Sep 2010 09:57:33 -0700
Message-ID: <4C866EFD.4060404@hp.com>
References: <AANLkTikMPENe011GxK15TNTXwdckZSSYfb=3pdDwfUeG@mail.gmail.com>	<20100906.221644.123986391.davem@davemloft.net>	<AANLkTik75BGz=csDKVRk+Ni9__MqXMpHeqi_sHniu09A@mail.gmail.com>	<20100906.223010.173858342.davem@davemloft.net> <1283859552.2338.402.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, leandroal@gmail.com,
	netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:2253 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758058Ab0IGQ5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 12:57:37 -0400
In-Reply-To: <1283859552.2338.402.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Is there a hard requirement about segment size being at most half the
> window ?

In the deep, dark, past of other stacks, there were concerns about devolving 
into stop-start.  I suppose from a theoretical standpoint, there is a chance 
that MSS==window, coupled with immediate ACKnowledgement on the receiver could 
send zero windows that might elicit undesirable probes?

rick jones
