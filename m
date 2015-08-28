From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8169: Add software counter for multicast
 packages
Date: Fri, 28 Aug 2015 13:23:05 -0700 (PDT)
Message-ID: <20150828.132305.59133940834058930.davem@davemloft.net>
References: <1440688308-24649-1-git-send-email-vinschen@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, nic_swsd@realtek.com,
	ivecera@redhat.com
To: vinschen@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797AbbH1UXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 16:23:09 -0400
In-Reply-To: <1440688308-24649-1-git-send-email-vinschen@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corinna Vinschen <vinschen@redhat.com>
Date: Thu, 27 Aug 2015 17:11:48 +0200

> The multicast hardware counter on 8168/8111 chips is only 32 bit while the
> statistics in struct rtnl_link_stats64 are 64 bit.  Given that statistics
> are requested on an irregular basis, an overflow of the hardware counter
> can go unnoticed.  To count even very large numbers of multicast packets
> reliably, add a software counter and remove previously applied code to
> fill the multicast field requested by @rtl8169_get_stats64 with the values
> read from the rx_multicast hardware counter.
> 
> Signed-off-by: Corinna Vinschen <vinschen@redhat.com>

Applied, thank you.
