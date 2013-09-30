From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/2] dev: always advertise rx_flags changes
 via netlink
Date: Mon, 30 Sep 2013 15:08:55 -0400 (EDT)
Message-ID: <20130930.150855.1177325698173768594.davem@davemloft.net>
References: <20130924094707.41641042@nehalam.linuxnetplumber.net>
	<1380103365-5185-1-git-send-email-nicolas.dichtel@6wind.com>
	<1380103365-5185-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35469 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755854Ab3I3TI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 15:08:58 -0400
In-Reply-To: <1380103365-5185-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 25 Sep 2013 12:02:45 +0200

> When flags IFF_PROMISC and IFF_ALLMULTI are changed, netlink messages are not
> consistent. For example, if a multicast daemon is running (flag IFF_ALLMULTI
> set in dev->flags but not dev->gflags, ie not exported to userspace) and then a
> user sets it via netlink (flag IFF_ALLMULTI set in dev->flags and dev->gflags, ie
> exported to userspace), no netlink message is sent.
> Same for IFF_PROMISC and because dev->promiscuity is exported via
> IFLA_PROMISCUITY, we may send a netlink message after each change of this
> counter.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
