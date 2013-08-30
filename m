From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: fix typo in assignment
Date: Fri, 30 Aug 2013 17:31:26 -0400 (EDT)
Message-ID: <20130830.173126.128593611207734649.davem@davemloft.net>
References: <1377689671-28666-1-git-send-email-ljaenicke@innominate.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ljaenicke@innominate.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612Ab3H3Vb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:31:28 -0400
In-Reply-To: <1377689671-28666-1-git-send-email-ljaenicke@innominate.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lutz Jaenicke <ljaenicke@innominate.com>
Date: Wed, 28 Aug 2013 13:34:31 +0200

> commit 3b04ddde02cf1b6f14f2697da5c20eca5715017f
> "[NET]: Move hardware header operations out of netdevice."
> moved the handling into macvlan setup adding
>   dev->header_ops         = &macvlan_hard_header_ops,
> At the end of the line the ',' should have been a ';'
> 
> Signed-off-by: Lutz Jaenicke <ljaenicke@innominate.com>

This is a harmless error, because semantically it causes no bug.

So this is a cleanup and I've thus applied it to net-next, thanks.
