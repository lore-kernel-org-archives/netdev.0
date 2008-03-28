From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] [NET]: uninline dev_alloc_skb, de-bloats a lot
Date: Thu, 27 Mar 2008 17:52:12 -0700 (PDT)
Message-ID: <20080327.175212.119805454.davem@davemloft.net>
References: <1206621486-5408-3-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1206621486-5408-4-git-send-email-ilpo.jarvinen@helsinki.fi>
	<200803280036.59311.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	acme@redhat.com
To: vda.linux@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50234
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752839AbYC1AwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 20:52:12 -0400
In-Reply-To: <200803280036.59311.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Vlasenko <vda.linux@googlemail.com>
Date: Fri, 28 Mar 2008 00:36:59 +0100

> Can you add a comment which explains the intent?
> 
> +struct sk_buff *dev_alloc_skb(unsigned int length)
> +{
> +       /* There is more code here than it seems:
> +        * __dev_alloc_skb is an inline */
> +	return __dev_alloc_skb(length, GFP_ATOMIC);
> +}
> +EXPORT_SYMBOL(dev_alloc_skb);

I've applied his patch already, if you want this comment
please submit the patch to add it and also please use
the correct formatting of the comment.
