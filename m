From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [NET]: Fix TX bug VLAN in VLAN
Date: Mon, 26 Nov 2007 19:26:32 +0800
Message-ID: <20071126112631.GA26599@gondor.apana.org.au>
References: <003f01c82dca$305acd40$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, tristan_schmelcher@alumni.uwaterloo.ca,
	acme@ghostprotocols.net
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4509 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752396AbXKZL0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 06:26:36 -0500
Content-Disposition: inline
In-Reply-To: <003f01c82dca$305acd40$9c94fea9@jason>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 12:12:52PM +0000, Joonwoo Park wrote:
> This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=8766
> 
> Is it possible? 
> BUG((veth->h_vlan_proto != htons(ETH_P_8021Q)) && !(VLAN_DEV_INFO(dev)->flags & VLAN_FLAG_REORDER_HDR))
> I'm afraid, queued packet before vconfig set_flag would do that.

Yes, AF_PACKET would do that.  So you should check both.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
