From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm/br2684: netif_stop_queue() when atm device busy
 and netif_wake_queue() when we can send packets again.
Date: Wed, 02 Sep 2009 23:27:07 -0700 (PDT)
Message-ID: <20090902.232707.93089975.davem@davemloft.net>
References: <1251545092-18081-1-git-send-email-karl@hiramoto.org>
	<200908311429.n7VETlTi000764@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, karl@hiramoto.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48329
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754480AbZICG0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 02:26:52 -0400
In-Reply-To: <200908311429.n7VETlTi000764@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Date: Mon, 31 Aug 2009 10:29:47 -0400

> This patch removes the call to dev_kfree_skb() when the atm device is busy.
> Calling dev_kfree_skb() causes heavy packet loss then the device is under
> heavy load, the more correct behavior should be to stop the upper layers,
> then when the lower device can queue packets again wake the upper layers.
> 
> Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
> Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

Applied to net-next-2.6, but Chas your email client corrupted
the patch by breaking up long lines:

> @@ -142,6 +142,22 @@ static struct net_device *br2684_find_dev(const struct br
> 2684_if_spec *s)

Like that.
