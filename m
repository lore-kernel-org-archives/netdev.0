From: David Miller <davem@davemloft.net>
Subject: Re: [NET] Update documentation of skb_linearize
Date: Fri, 10 Nov 2006 14:53:46 -0800 (PST)
Message-ID: <20061110.145346.125893910.davem@davemloft.net>
References: <20061110213043.GB9453@electric-eye.fr.zoreil.com>
	<20061110133555.7400e555@freekitty>
	<20061110220355.GC9453@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, dale@farnsworth.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51388
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424447AbWKJWxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 17:53:44 -0500
To: romieu@fr.zoreil.com
In-Reply-To: <20061110220355.GC9453@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 10 Nov 2006 23:03:55 +0100

> The data is not released.

Yes it is.

If the non-linear SKB has data in pages, we copy that data from the
pages into the new linear skb->data area and release the paged data.
