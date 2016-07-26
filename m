From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH] macsec: ensure rx_sa is set when validation is disabled
Date: Tue, 26 Jul 2016 13:26:10 +0200
Message-ID: <20160726112610.GA26461@bistromath.localdomain>
References: <1469528693-6578-1-git-send-email-bgalvani@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Beniamino Galvani <bgalvani@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39518 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753564AbcGZL0O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 07:26:14 -0400
Content-Disposition: inline
In-Reply-To: <1469528693-6578-1-git-send-email-bgalvani@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-07-26, 12:24:53 +0200, Beniamino Galvani wrote:
> macsec_decrypt() is not called when validation is disabled and so
> macsec_skb_cb(skb)->rx_sa is not set; but it is used later in
> macsec_post_decrypt(), ensure that it's always initialized.
> 
> Signed-off-by: Beniamino Galvani <bgalvani@redhat.com>
> ---
>  drivers/net/macsec.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

This patch should go in the 'net' tree.

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Acked-by: Sabrina Dubroca <sd@queasysnail.net>

-- 
Sabrina
