From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/3] make mac programming for virtio net more robust
Date: Mon, 21 Jan 2013 14:09:20 -0500 (EST)
Message-ID: <20130121.140920.2221386686285571275.davem@davemloft.net>
References: <1358767043-24548-1-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, rusty@rustcorp.com.au,
	qemu-devel@nongnu.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: akong@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326Ab3AUTJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 14:09:23 -0500
In-Reply-To: <1358767043-24548-1-git-send-email-akong@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amos Kong <akong@redhat.com>
Date: Mon, 21 Jan 2013 19:17:20 +0800

> Currenly mac is programmed byte by byte. This means that we
> have an intermediate step where mac is wrong. 
> 
> Third patch introduced a new vq control command to set mac
> address, it's atomic.
> 
> V2: check return of sending command, delay eth_mac_addr()
> V3: restore software address when fail to set hardware address
> V4: split eth_mac_addr, fix error handle
> V5: rebase patches to net-next tree

I'll apply this series, thanks.
