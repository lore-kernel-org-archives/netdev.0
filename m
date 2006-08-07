From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] move skb->dev assignment into netdev_alloc_skb
Date: Mon, 07 Aug 2006 16:10:56 -0700 (PDT)
Message-ID: <20060807.161056.85410448.davem@davemloft.net>
References: <20060805130109.GB24121@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41142
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751155AbWHGXKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:10:55 -0400
To: hch@lst.de
In-Reply-To: <20060805130109.GB24121@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Sat, 5 Aug 2006 15:01:09 +0200

> All caller of netdev_alloc_skb need to assign skb->dev shortly
> afterwards.  Move it into common code.
> 
> I also had to fixup a little bit of the surrounding control flow in
> e1000 - it was just too convoluted.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Since the e1000 change is non-trivial I'm not going to bypass
the driver author on it, sorry.

What I did do was put the netdev_alloc_skb() change into my
tree, and since I'm co-author of the tg3 driver I'll apply
that bit too.

The e1000 bit will need to go through the e1000 maintainers.

Thanks.
