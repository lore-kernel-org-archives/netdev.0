From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] 6lowpan: handle only real link-local
 addresses
Date: Wed, 14 Aug 2013 12:53:46 -0700 (PDT)
Message-ID: <20130814.125346.585011183381258117.davem@davemloft.net>
References: <1376478067-3371-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758543Ab3HNTxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 15:53:49 -0400
In-Reply-To: <1376478067-3371-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Wed, 14 Aug 2013 13:01:07 +0200

> A link-local address isn't fe80::/10 it's fe80::/64
> see http://tools.ietf.org/html/rfc4291#section-2.5.6
> for more details.
> 
> Also fix a comment issue "local link" -> "link-local"
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> Reviewed-by: Werner Almesberger <werner@almesberger.net>

You still haven't addressed my biggest concern.

What order do I apply this patch relative to the other 6?

Don't make me guess, instead place this patch into the necessary
place within the series of 6 patches.

I'm not applying any of this until you can submit it properly.

Thanks.
