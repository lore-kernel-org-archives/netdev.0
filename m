From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: Eliminate kmalloc in netlink dump operation.
Date: Thu, 15 Aug 2013 15:51:45 -0700 (PDT)
Message-ID: <20130815.155145.284061591768566029.davem@davemloft.net>
References: <1376605866-6808-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46933 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929Ab3HOWvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 18:51:45 -0400
In-Reply-To: <1376605866-6808-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 15 Aug 2013 15:31:06 -0700

> Following patch stores struct netlink_callback in netlink_sock
> to avoid allocating and freeing it on every netlink dump msg.
> Only one dump operation is allowed for a given socket at a time
> therefore we can safely convert cb pointer to cb struct inside
> netlink_sock.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Your analysis looks good, applied, thanks.
