From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net:ppp: replace too strict capability restriction on
 opening /dev/ppp
Date: Sat, 18 Jun 2016 22:24:18 -0700 (PDT)
Message-ID: <20160618.222418.1416412894394180688.davem@davemloft.net>
References: <15AED149-BC4D-4B8F-B173-3F652A46FA35@tuna.tsinghua.edu.cn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	richard.weinberger@gmail.com, g.nault@alphalink.fr,
	shankerwangmiao@gmail.com
To: miao.wang@tuna.tsinghua.edu.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbcFSFYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 01:24:20 -0400
In-Reply-To: <15AED149-BC4D-4B8F-B173-3F652A46FA35@tuna.tsinghua.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shanker Wang <miao.wang@tuna.tsinghua.edu.cn>
Date: Sun, 19 Jun 2016 07:21:27 +0200

> This patch removes the check for CAP_NET_ADMIN in the initial namespace
> when opening /dev/open. Instead, CAP_NET_ADMIN is checked in the user
> namespace the net namespace was created so that /dev/ppp cat get opened
> in a unprivileged container.
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Richard Weinberger <richard.weinberger@gmail.com>
> Cc: Guillaume Nault <g.nault@alphalink.fr>
> Cc: Miao Wang <shankerwangmiao@gmail.com>
> Signed-off-by: Miao Wang <miao.wang@tuna.tsinghua.edu.cn>

Why are you posting this again?
