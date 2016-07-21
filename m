From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] samples: Add an IPv6 '-6' option to the
 pktgen scripts
Date: Wed, 20 Jul 2016 22:16:14 -0700 (PDT)
Message-ID: <20160720.221614.511465646516676662.davem@davemloft.net>
References: <1469054923-4178431-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60882 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbcGUFQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 01:16:16 -0400
In-Reply-To: <1469054923-4178431-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Wed, 20 Jul 2016 15:48:43 -0700

> Add a '-6' option to the sample pktgen scripts for sending out
> IPv6 packets.
> 
> [root@kerneldev010.prn1 ~/pktgen]# ./pktgen_sample03_burst_single_flow.sh -i eth0 -s 64 -d fe80::f652:14ff:fec2:a14c -m f4:52:14:c2:a1:4c -b 32 -6
> 
> [root@kerneldev011.prn1 ~]# tcpdump -i eth0 -nn -c3 port 9
> tcpdump: WARNING: eth0: no IPv4 address assigned
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
> 14:38:51.815297 IP6 fe80::f652:14ff:fec2:2ad2.9 > fe80::f652:14ff:fec2:a14c.9: UDP, length 16
> 14:38:51.815311 IP6 fe80::f652:14ff:fec2:2ad2.9 > fe80::f652:14ff:fec2:a14c.9: UDP, length 16
> 14:38:51.815313 IP6 fe80::f652:14ff:fec2:2ad2.9 > fe80::f652:14ff:fec2:a14c.9: UDP, length 16
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Applied.
