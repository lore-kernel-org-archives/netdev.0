From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] ip6_tunnel: use the right netns in ioctl
 handler
Date: Wed, 16 Apr 2014 15:16:37 -0400 (EDT)
Message-ID: <20140416.151637.172374036248006994.davem@davemloft.net>
References: <1397639974-22693-1-git-send-email-nicolas.dichtel@6wind.com>
	<1397639974-22693-3-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47518 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756140AbaDPTQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 15:16:38 -0400
In-Reply-To: <1397639974-22693-3-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 16 Apr 2014 11:19:34 +0200

> Because the netdevice may be in another netns than the i/o netns, we should
> use the i/o netns instead of dev_net(dev).
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
