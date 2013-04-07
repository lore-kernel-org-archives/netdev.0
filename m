From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests: net: add PF_PACKET TPACKET
 v1/v2/v3 selftests
Date: Sun, 07 Apr 2013 17:02:43 -0400 (EDT)
Message-ID: <20130407.170243.1891515530961395735.davem@davemloft.net>
References: <1364943651-3346-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934312Ab3DGVCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 17:02:44 -0400
In-Reply-To: <1364943651-3346-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed,  3 Apr 2013 01:00:51 +0200

> This patch adds a simple test case that probes the packet socket's
> TPACKET_V1, TPACKET_V2 and TPACKET_V3 behavior regarding mmap(2)'ed
> I/O for a small burst of 100 packets. The test currently runs for ...
> 
>   TPACKET_V1: RX_RING, TX_RING
>   TPACKET_V2: RX_RING, TX_RING
>   TPACKET_V3: RX_RING
> 
> ... and will output on success:
> 
>   test: TPACKET_V1 with PACKET_RX_RING .................... 100 pkts (9600 bytes)
>   test: TPACKET_V1 with PACKET_TX_RING .................... 100 pkts (9600 bytes)
>   test: TPACKET_V2 with PACKET_RX_RING .................... 100 pkts (9600 bytes)
>   test: TPACKET_V2 with PACKET_TX_RING .................... 100 pkts (9600 bytes)
>   test: TPACKET_V3 with PACKET_RX_RING .................... 100 pkts (9600 bytes)
>   OK. All tests passed
> 
> Reusable parts of psock_fanout.c have been put into a psock_lib.h
> file for common usage. Test case successfully tested on x86_64.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks!
