From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec 1/2] xfrm: revert ipv4 mtu determination to dst_mtu
Date: Tue, 27 Aug 2013 11:22:21 +0200
Message-ID: <20130827092221.GA7660@secunet.com>
References: <20130826103119.GA30465@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48775 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752623Ab3H0JWY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 05:22:24 -0400
Content-Disposition: inline
In-Reply-To: <20130826103119.GA30465@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 26, 2013 at 12:31:19PM +0200, Hannes Frederic Sowa wrote:
> In commit 0ea9d5e3e0e03a63b11392f5613378977dae7eca ("xfrm: introduce
> helper for safe determination of mtu") I switched the determination of
> ipv4 mtus from dst_mtu to ip_skb_dst_mtu. This was an error because in
> case of IP_PMTUDISC_PROBE we fall back to the interface mtu, which is
> never correct for ipv4 ipsec.
> 
> This patch partly reverts 0ea9d5e3e0e03a63b11392f5613378977dae7eca
> ("xfrm: introduce helper for safe determination of mtu").
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied to ipsec.
