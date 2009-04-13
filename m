From: David Miller <davem@davemloft.net>
Subject: Re: gro: Normalise skb before bypassing GRO on netpoll VLAN path
Date: Mon, 13 Apr 2009 15:45:49 -0700 (PDT)
Message-ID: <20090413.154549.107046942.davem@davemloft.net>
References: <20090413144101.GA17575@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42823
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751496AbZDMWp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 18:45:58 -0400
In-Reply-To: <20090413144101.GA17575@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 13 Apr 2009 22:41:01 +0800

> gro: Normalise skb before bypassing GRO on netpoll VLAN path
> 
> When we detect netpoll RX on the GRO VLAN path we bail out and
> call the normal VLAN receive handler.  However, the packet needs
> to be normalised by calling eth_type_trans since that's what the
> normal path expects (normally the GRO path does the fixup).
> 
> This patch adds the necessary call to vlan_gro_frags.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
