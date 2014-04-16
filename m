From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] sit: use the right netns in ioctl handler
Date: Wed, 16 Apr 2014 15:16:32 -0400 (EDT)
Message-ID: <20140416.151632.711828908301681249.davem@davemloft.net>
References: <1397639974-22693-1-git-send-email-nicolas.dichtel@6wind.com>
	<1397639974-22693-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756062AbaDPTQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 15:16:33 -0400
In-Reply-To: <1397639974-22693-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 16 Apr 2014 11:19:33 +0200

> Because the netdevice may be in another netns than the i/o netns, we should
> use the i/o netns instead of dev_net(dev).
> 
> Note that netdev_priv(dev) cannot bu NULL, hence we can remove these useless
> checks.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
