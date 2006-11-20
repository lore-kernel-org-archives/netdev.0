From: David Miller <davem@davemloft.net>
Subject: Re: [patch] Performance enhancement patches for SB1250 MAC
Date: Mon, 20 Nov 2006 15:58:25 -0800 (PST)
Message-ID: <20061120.155825.59657887.davem@davemloft.net>
References: <F09F8223E8BE7D42BDA1800B19F3440D922017@ALA-MAIL03.corp.ad.wrs.com>
	<20061120153548.71f90b7a@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.yang@windriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:7099
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966869AbWKTX6V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 18:58:21 -0500
To: shemminger@osdl.org
In-Reply-To: <20061120153548.71f90b7a@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 20 Nov 2006 15:35:48 -0800

> I am not the final decider on this. Ask Jeff/David? Maybe there is some
> more general work that can be done to speed up skb allocation.

We used to have a skb_head per-cpu cache in skbuff.c but we killed
it because SLAB was nearly as good and using generic code always
trumps localized hacks like this.

I suggest we don't regress in this area.
