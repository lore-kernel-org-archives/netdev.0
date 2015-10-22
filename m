From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Fix potential NULL pointer access and memory leak
 in ISDN layer2 functions
Date: Thu, 22 Oct 2015 07:24:08 -0700 (PDT)
Message-ID: <20151022.072408.3523117912468128.davem@davemloft.net>
References: <1445429919-22924-1-git-send-email-keil@b1-systems.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org, wuninsu@gmail.com
To: keil@b1-systems.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756888AbbJVOHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 10:07:41 -0400
In-Reply-To: <1445429919-22924-1-git-send-email-keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <keil@b1-systems.de>
Date: Wed, 21 Oct 2015 14:18:37 +0200

> Insu Yun did brinup the issue with not checking the skb_clone() return
> value in the layer2 I-frame ull functions.
> This series fix the issue in a way which avoid protocol violations/data loss
> on a temporary memory shortage.

Series applied, thanks Karsten.
