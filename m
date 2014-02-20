From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] veth: Fix vlan_features so as to be able to use
 stacked vlan interfaces
Date: Thu, 20 Feb 2014 02:16:41 -0500 (EST)
Message-ID: <20140220.021641.1381577589162092169.davem@davemloft.net>
References: <1392726009-8083-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fbl@redhat.com, netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51238 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbaBTHQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 02:16:43 -0500
In-Reply-To: <1392726009-8083-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Tue, 18 Feb 2014 21:20:08 +0900

> Even if we create a stacked vlan interface such as veth0.10.20, it sends
> single tagged frames (tagged with only vid 10).
> Because vlan_features of a veth interface has the
> NETIF_F_HW_VLAN_[CTAG/STAG]_TX bits, veth0.10 also has that feature, so
> dev_hard_start_xmit(veth0.10) doesn't call __vlan_put_tag() and
> vlan_dev_hard_start_xmit(veth0.10) overwrites vlan_tci.
> This prevents us from using a combination of 802.1ad and 802.1Q
> in containers, etc.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied and queued up for -stable.
