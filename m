From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/2] vxlan: leave multicast group when
 vxlan device down
Date: Wed, 11 Dec 2013 14:21:55 -0500 (EST)
Message-ID: <20131211.142155.331826013979440760.davem@davemloft.net>
References: <1386664653-27082-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1386664653-27082-2-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339Ab3LKTV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 14:21:56 -0500
In-Reply-To: <1386664653-27082-2-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Tue, 10 Dec 2013 16:37:33 +0800

> vxlan_group_used only allows device to leave multicast group
> when the remote_ip of this vxlan device is difference from
> other vxlan devices' remote_ip. this will cause device not
> leave multicast group untile the vn_sock of this vxlan deivce
> being released.
> 
> The check in vxlan_group_used is not quite precise. since even
> the remote_ip is same, but these vxlan devices may use different
> lower devices, and they may use different vn_socks.
> 
> Only when some vxlan devices use the same vn_sock,same lower
> device and same remote_ip, the mc_list of the vn_sock should
> not be changed.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied.
