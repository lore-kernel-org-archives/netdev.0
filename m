From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net]: ipv6: drop frames with attached skb->sk in
 forwarding
Date: Mon, 14 Mar 2016 15:41:11 -0700
Message-ID: <1457995271.31401.29.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160314223243.19F7F38508B@fruggeri-Arora18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: fruggeri@arista.com, netdev@vger.kernel.org,
	sasha.levin@oracle.com, davem@davemloft.net,
	hannes@stressinduktion.org
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35718 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbcCNWlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 18:41:13 -0400
Received: by mail-pa0-f43.google.com with SMTP id td3so139148825pab.2
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 15:41:13 -0700 (PDT)
In-Reply-To: <20160314223243.19F7F38508B@fruggeri-Arora18.sjc.aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-14 at 15:32 -0700, Francesco Ruggeri wrote:
> Should 9ef2e965e554 ["ipv6: drop frames with attached skb->sk in forwarding"]
> be considered for stable?
> It did address a crash in ip6_skb_dst_mtu that I was seeing in 3.18, where
> an incoming packet found an inet_timewait_sock in tcp_v6_early_demux
> but was later ip6_forward'ed (the local address that had been used for
> the tcp connection had been moved out of the router).

Yes, definitely stable material.
