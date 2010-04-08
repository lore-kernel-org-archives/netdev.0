From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter: Only do skb_checksum_help on CHECKSUM_PARTIAL in	nfnetlink_queue
Date: Thu, 08 Apr 2010 14:55:08 +0200
Message-ID: <4BBDD22C.2010508@trash.net>
References: <20100408123545.GA23829@gondor.apana.org.au> <20100408123930.GA23910@gondor.apana.org.au> <20100408124158.GB23910@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36741 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757876Ab0DHMzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 08:55:09 -0400
In-Reply-To: <20100408124158.GB23910@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> netfilter: Only do skb_checksum_help on CHECKSUM_PARTIAL in nfnetlink_queue
> 
> As we will set ip_summed to CHECKSUM_NONE when necessary in
> nfqnl_mangle, there is no need to zap CHECKSUM_COMPLETE in
> nfqnl_build_packet_message.

Applied, thanks.
