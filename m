From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH net-next] net ipv6: Remove rebundant
 rt6i_nsiblings initialization
Date: Wed, 24 Jul 2013 14:26:25 -0700 (PDT)
Message-ID: <20130724.142625.2136202418070001578.davem@davemloft.net>
References: <1374474012-22640-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab3GXV00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 17:26:26 -0400
In-Reply-To: <1374474012-22640-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Mon, 22 Jul 2013 14:20:12 +0800

> Seting rt->rt6i_nsiblings to zero is rebundant, because above memset
> zeroed the rest of rt excluding the first dst memember.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
