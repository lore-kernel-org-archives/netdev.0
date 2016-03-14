From: fruggeri@aristanetworks.com (Francesco Ruggeri)
Subject: Re: [PATCH net]: ipv6: drop frames with attached skb->sk in
 forwarding
Date: Mon, 14 Mar 2016 15:32:43 -0700
Message-ID: <20160314223243.19F7F38508B@fruggeri-Arora18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: fruggeri@arista.com, netdev@vger.kernel.org,
	sasha.levin@oracle.com, davem@davemloft.net,
	hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:59377 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751784AbcCNWco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 18:32:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Should 9ef2e965e554 ["ipv6: drop frames with attached skb->sk in forwarding"]
be considered for stable?
It did address a crash in ip6_skb_dst_mtu that I was seeing in 3.18, where
an incoming packet found an inet_timewait_sock in tcp_v6_early_demux
but was later ip6_forward'ed (the local address that had been used for
the tcp connection had been moved out of the router).

Thanks,
Francesco Ruggeri
