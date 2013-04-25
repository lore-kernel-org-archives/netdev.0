From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] packet: account statistics only in
 tpacket_stats_u
Date: Thu, 25 Apr 2013 01:30:03 -0400 (EDT)
Message-ID: <20130425.013003.906198891652585954.davem@davemloft.net>
References: <1366387949-9161-1-git-send-email-dborkman@redhat.com>
	<1366387949-9161-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48110 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab3DYFaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:30:05 -0400
In-Reply-To: <1366387949-9161-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 19 Apr 2013 18:12:29 +0200

> Currently, packet_sock has a struct tpacket_stats stats member for
> TPACKET_V1 and TPACKET_V2 statistic accounting, and with TPACKET_V3
> ``union tpacket_stats_u stats_u'' was introduced, where however only
> statistics for TPACKET_V3 are held, and when copied to user space,
> TPACKET_V3 does some hackery and access also tpacket_stats' stats,
> although everything could have been done within the union itself.
> 
> Unify accounting within the tpacket_stats_u union so that we can
> remove 8 bytes from packet_sock that are there unnecessary. Note that
> even if we switch to TPACKET_V3 and would use non mmap(2)ed option,
> this still works due to the union with same types + offsets, that are
> exposed to the user space.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
