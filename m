From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/3] net: split eth_mac_addr for better error
 handling
Date: Sun, 20 Jan 2013 23:14:32 -0500 (EST)
Message-ID: <20130120.231432.1625470984232658368.davem@davemloft.net>
References: <1358649789-2338-1-git-send-email-akong@redhat.com>
	<1358649789-2338-3-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, rusty@rustcorp.com.au, qemu-devel@nongnu.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: akong@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617Ab3AUEOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 23:14:35 -0500
In-Reply-To: <1358649789-2338-3-git-send-email-akong@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akong@redhat.com
Date: Sun, 20 Jan 2013 10:43:08 +0800

> From: Stefan Hajnoczi <stefanha@gmail.com>
> 
> When we set mac address, software mac address in system and hardware mac
> address all need to be updated. Current eth_mac_addr() doesn't allow
> callers to implement error handling nicely.
> 
> This patch split eth_mac_addr() to prepare part and real commit part,
> then we can prepare first, and try to change hardware address, then do
> the real commit if hardware address is set successfully.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@gmail.com>
> Signed-off-by: Amos Kong <akong@redhat.com>

This patch doesn't apply to net-next.
