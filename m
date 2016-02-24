From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next][v2] bridge: allow the maximum mtu to 64k
Date: Wed, 24 Feb 2016 15:57:17 -0500 (EST)
Message-ID: <20160224.155717.1483714196085798853.davem@davemloft.net>
References: <1456189256-7811-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757296AbcBXVWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 16:22:47 -0500
In-Reply-To: <1456189256-7811-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Tue, 23 Feb 2016 09:00:56 +0800

> This is especially annoying for the virtualization case because the
> KVM's tap driver will by default adopt the bridge's MTU on startup
> making it impossible (without the workaround) to use a large MTU on the
> guest VMs.

So if the TAP device adopts the bridge's MTU, and then a device is
enslaved to the bridge that has a "smaller than 64k" MTU, what
propagates that MTU change back to the TAP device?

I really want to understand how this is supposed to work.
