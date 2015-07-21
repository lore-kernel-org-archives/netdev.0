From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] inet: frags: fix defragmented packet's IP
 header for af_packet
Date: Tue, 21 Jul 2015 10:37:53 -0700 (PDT)
Message-ID: <20150721.103753.1054475332849936583.davem@davemloft.net>
References: <1437464639.1026.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edjee@google.com, willemb@google.com,
	hkchu@google.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933274AbbGURh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 13:37:57 -0400
In-Reply-To: <1437464639.1026.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Jul 2015 09:43:59 +0200

> From: Edward Hyunkoo Jee <edjee@google.com>
> 
> When ip_frag_queue() computes positions, it assumes that the passed
> sk_buff does not contain L2 headers.
> 
> However, when PACKET_FANOUT_FLAG_DEFRAG is used, IP reassembly
> functions can be called on outgoing packets that contain L2 headers. 
> 
> Also, IPv4 checksum is not corrected after reassembly.
> 
> Fixes: 7736d33f4262 ("packet: Add pre-defragmentation support for ipv4 fanouts.")
> Signed-off-by: Edward Hyunkoo Jee <edjee@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
