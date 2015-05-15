From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3] ip_tunnel: Report Rx dropped in
 ip_tunnel_get_stats64
Date: Thu, 14 May 2015 22:33:13 -0400 (EDT)
Message-ID: <20150514.223313.2022997448767456512.davem@davemloft.net>
References: <20150514212855.1301.93235.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423545AbbEOCdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 22:33:15 -0400
In-Reply-To: <20150514212855.1301.93235.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Thu, 14 May 2015 14:31:28 -0700

> The rx_dropped stat wasn't being reported when ip_tunnel_get_stats64 was
> called.  This was leading to some confusing results in my debug as I was
> seeing rx_errors increment but no other value which pointed me toward the
> type of error being seen.
> 
> This change corrects that by using netdev_stats_to_stats64 to copy all
> available dev stats instead of just the few that were hand picked.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Applied, thanks Alexander.
