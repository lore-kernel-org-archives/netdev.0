From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drop_monitor: convert some kfree_skb call sites to
 consume_skb
Date: Tue, 20 Jul 2010 13:28:21 -0700 (PDT)
Message-ID: <20100720.132821.221599763.davem@davemloft.net>
References: <20100720164556.GF1995@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@zeniv.linux.org.uk, eparis@redhat.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51308
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761496Ab0GTU2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 16:28:05 -0400
In-Reply-To: <20100720164556.GF1995@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 20 Jul 2010 12:45:56 -0400

> Convert a few calls from kfree_skb to consume_skb
> 
> Noticed while I was working on dropwatch that I was detecting lots of internal
> skb drops in several places.  While some are legitimate, several were not,
> freeing skbs that were at the end of their life, rather than being discarded due
> to an error.  This patch converts those calls sites from using kfree_skb to
> consume_skb, which quiets the in-kernel drop_monitor code from detecting them as
> drops.  Tested successfully by myself
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
