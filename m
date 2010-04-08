From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter: Only do skb_checksum_help on CHECKSUM_PARTIAL in	ip6_queue
Date: Thu, 08 Apr 2010 14:54:11 +0200
Message-ID: <4BBDD1F3.4000409@trash.net>
References: <20100408123545.GA23829@gondor.apana.org.au> <20100408123930.GA23910@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36727 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757876Ab0DHMyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 08:54:13 -0400
In-Reply-To: <20100408123930.GA23910@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Apr 08, 2010 at 08:35:45PM +0800, Herbert Xu wrote:
>> netfilter: Only do skb_checksum_help on CHECKSUM_PARTIAL in ip_queue
> 
> Doh! There are three of these queue beasts.

;)

> netfilter: Only do skb_checksum_help on CHECKSUM_PARTIAL in ip6_queue
> 
> As we will set ip_summed to CHECKSUM_NONE when necessary in
> ipq_mangle_ipv6, there is no need to zap CHECKSUM_COMPLETE in
> ipq_build_packet_message.

Also applied, thanks.
