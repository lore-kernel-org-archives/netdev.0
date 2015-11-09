From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/2] packet: do skb_probe_transport_header when we
 actually have data
Date: Mon, 09 Nov 2015 12:31:59 +0100
Message-ID: <5640842F.3000109@iogearbox.net>
References: <1446900176.17135.4.camel@edumazet-glaptop2.roam.corp.google.com>	<20151107.133502.833614670001999282.davem@davemloft.net>	<1446922430.17135.13.camel@edumazet-glaptop2.roam.corp.google.com> <20151107.172928.239564395518699740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, edumazet@google.com, willemb@google.com,
	tklauser@distanz.ch, netdev@vger.kernel.org, jasowang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33354 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbbKILcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 06:32:10 -0500
In-Reply-To: <20151107.172928.239564395518699740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07/2015 11:29 PM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 07 Nov 2015 10:53:50 -0800
>
>> Well, imagine following scenario (a real one, as I use it all of
>> time, thus how I discovered all trafgen traffic ends up on one slave
>> only)
>>
>> Even if qdisc is bypassed on the bond0, the current handling does
>> not prevent going to the slave qdiscs.
>
> Ok, depending upon the semantics Daniel intended, we may have to add
> a qdisc bypass boolean bit to SKBs.

It was resembling pktgen to some extend, only to be more flexible in
terms of defining packet payload (trafgen, I mean). Yes, pktgen has
the same issue on that regard, hmm I'm not yet sure, though, if it's
worth burning an extra skb bit for both cases.
