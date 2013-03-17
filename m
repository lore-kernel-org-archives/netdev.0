From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: fix occasional statistics off-by-4GB error
Date: Sun, 17 Mar 2013 14:24:25 -0400 (EDT)
Message-ID: <20130317.142425.1713640249735424829.davem@davemloft.net>
References: <CANP3RGdWMHv-7TZ4fvASrmz7NXkO7B2g2RCZwV8ecExUsQTQ2w@mail.gmail.com>
	<1363384577-21287-1-git-send-email-zenczykowski@gmail.com>
	<504C9EFCA2D0054393414C9CB605C37F20BE6A2B@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zenczykowski@gmail.com, maze@google.com, netdev@vger.kernel.org,
	yuvalmin@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46820 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756411Ab3CQSY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 14:24:28 -0400
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F20BE6A2B@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Sun, 17 Mar 2013 13:10:37 +0000

> Probably this commit resolved the issue:
> 
> commit bef05406ac0ea6f468e1e25e9934f3011ea9259b
> Author: Dmitry Kravkov <dmitry@broadcom.com>
> Date:   Tue Sep 11 04:34:08 2012 +0000
> 
>     bnx2x: Avoid sending multiple statistics queries
> 
> Can you try it pls?

These are completely seperate bugs.

The macro in question does not handle rollover of the lower 32-bits of
the statistic properly at all, and therefore Maciej's patch should be
applied and queud up for -stable.

Please give it your ACK unless you can find a bug in his change.
