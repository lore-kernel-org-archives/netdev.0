From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: allow packets defragmentation not only for
 hash fanout type
Date: Sat, 21 Feb 2015 23:00:33 -0500 (EST)
Message-ID: <20150221.230033.1502768500202889696.davem@davemloft.net>
References: <1424409867-23041-1-git-send-email-al.drozdov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, edumazet@google.com, viro@zeniv.linux.org.uk,
	willemb@google.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: al.drozdov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37595 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbbBVEJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 23:09:30 -0500
In-Reply-To: <1424409867-23041-1-git-send-email-al.drozdov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Drozdov <al.drozdov@gmail.com>
Date: Fri, 20 Feb 2015 08:24:27 +0300

> Packets defragmentation was introduced for PACKET_FANOUT_HASH only,
> see 7736d33f4262 ("packet: Add pre-defragmentation support for ipv4
> fanouts")
> 
> It may be useful to have defragmentation enabled regardless of
> fanout type. Without that, the AF_PACKET user may have to:
> 1. Collect fragments from different rings
> 2. Defragment by itself
> 
> Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>

Seems reasonable, applied, thanks.
