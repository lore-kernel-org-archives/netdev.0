From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] xen-netback: support for control ring
Date: Thu, 12 May 2016 11:52:19 -0400 (EDT)
Message-ID: <20160512.115219.759608823316429913.davem@davemloft.net>
References: <1462979790-2824-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbcELPwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 11:52:22 -0400
In-Reply-To: <1462979790-2824-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Wed, 11 May 2016 16:16:26 +0100

> My recent patch to import an up-to-date include/xen/interface/io/netif.h
> from the Xen Project brought in the necessary definitions to support the
> new control shared ring and protocol. This patch series updates xen-netback
> to support the new ring.

I lost my copy of your V3 cover letter, so I'm replying to this one, but
be sure I tested V3 :-)

This doesn't build, please fix:

ERROR: "init_rcu_head" [drivers/net/xen-netback/xen-netback.ko] undefined!
ERROR: "destroy_rcu_head" [drivers/net/xen-netback/xen-netback.ko] undefined!
