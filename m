From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter: Only do skb_checksum_help on CHECKSUM_PARTIAL in	ip_queue
Date: Thu, 08 Apr 2010 14:53:09 +0200
Message-ID: <4BBDD1B5.9060205@trash.net>
References: <20100408123545.GA23829@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36690 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756937Ab0DHMxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 08:53:12 -0400
In-Reply-To: <20100408123545.GA23829@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Hi:
> 
> netfilter: Only do skb_checksum_help on CHECKSUM_PARTIAL in ip_queue
> 
> While doing yet another audit on ip_summed I noticed ip_queue
> calling skb_checksum_help unnecessarily.  As we will set ip_summed
> to CHECKSUM_NONE when necessary in ipq_mangle_ipv4, there is no
> need to zap CHECKSUM_COMPLETE in ipq_build_packet_message.

Applied, thanks Herbert.
