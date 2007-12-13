From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] HDLC driver: use unregister_netdev instead of
 unregister_netdevice
Date: Wed, 12 Dec 2007 19:22:09 -0800 (PST)
Message-ID: <20071212.192209.95259627.davem@davemloft.net>
References: <20071212.104614.208083873.davem@davemloft.net>
	<E1J2eW8-0000GQ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, jgarzik@pobox.com, khc@pm.waw.pl,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45421
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751024AbXLMDWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 22:22:10 -0500
In-Reply-To: <E1J2eW8-0000GQ-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Dec 2007 11:13:44 +0800

> Let's see who else is doing this:
> 
> [NET]: Check RTNL status in unregister_netdevice
> 
> The caller must hold the RTNL so let's check it in unregister_netdevice.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Good idea, applied to net-2.6.25, thanks.
