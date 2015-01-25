From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net: ipv6: Add sysctl entry to disable MTU
 updates from RA
Date: Sun, 25 Jan 2015 14:55:05 -0800 (PST)
Message-ID: <20150125.145505.1692145787461736994.davem@davemloft.net>
References: <1421773565-5181-1-git-send-email-harouth@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: harouth@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37793 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbbAYWzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 17:55:06 -0500
In-Reply-To: <1421773565-5181-1-git-send-email-harouth@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harout Hedeshian <harouth@codeaurora.org>
Date: Tue, 20 Jan 2015 10:06:05 -0700

> The kernel forcefully applies MTU values received in router
> advertisements provided the new MTU is less than the current. This
> behavior is undesirable when the user space is managing the MTU. Instead
> a sysctl flag 'accept_ra_mtu' is introduced such that the user space
> can control whether or not RA provided MTU updates should be applied. The
> default behavior is unchanged; user space must explicitly set this flag
> to 0 for RA MTUs to be ignored.
> 
> Signed-off-by: Harout Hedeshian <harouth@codeaurora.org>

Applied.
