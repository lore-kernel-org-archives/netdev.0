From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] add netdev_alloc_skb
Date: Wed, 26 Jul 2006 15:24:51 -0700 (PDT)
Message-ID: <20060726.152451.35043090.davem@davemloft.net>
References: <20060726113136.GA403@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38294
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751803AbWGZWYv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 18:24:51 -0400
To: hch@lst.de
In-Reply-To: <20060726113136.GA403@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Wed, 26 Jul 2006 13:31:36 +0200

> + *	%NULL is returned in there is no free memory. Although this function
> + *	allocates memory it can be called from an interrupt.
 ...
> + *	%NULL is returned in there is no free memory.

Looks like a typo in both cases, I think you mean
"NULL is returned _if_ there" not "in there"

I think I can queue this up for 2.6.19 if you fix
this typo, but I'm not going to slap the deprecated
marker on dev_alloc_skb() until all of the in-tree
cases are being taken care of.  It will just be a
bunch of pointless noise, and at worse it will push
the remaining conversions on some poor soul such as
Andrew :)
