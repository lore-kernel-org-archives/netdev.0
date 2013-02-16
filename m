From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next (V2)] ipv6: Queue fragments per interface
 for multicast/link-local addresses.
Date: Fri, 15 Feb 2013 22:25:18 -0800
Message-ID: <1360995918.19353.56.camel@edumazet-glaptop>
References: <511F1E03.9010205@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Ben Greear <greearb@candelatech.com>,
	Vlad Yasevich <vyasevic@redhat.com>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:62962 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab3BPGZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 01:25:21 -0500
Received: by mail-da0-f53.google.com with SMTP id w3so1705826dad.26
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 22:25:20 -0800 (PST)
In-Reply-To: <511F1E03.9010205@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-02-16 at 14:49 +0900, YOSHIFUJI Hideaki wrote:
> We should queue fragments for the same link-local address on
> different interfaces (e.g. fe80::1%eth0 and fe80::1%eth1) to the
> different queue, because of nature of addressing architecture.
> 
> Similarly, we should queue fragments for multicast on different
> interface to the different queue.  This is okay because
> application joins group on speicific interface, and multicast
> traffic is expected only on that interface.
> 
> CC: Ben Greear <greearb@candelatech.com>
> CC: Vlad Yasevich <vyasevic@redhat.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---

I would definitely ask advice from Patrick & Pablo on this patch.

If a router uses several links in aggregation (but no bonding dev), we
might break fragmentation/reassembly.
