From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sit: fix 4in4 + IPsec scenario
Date: Wed, 26 Jun 2013 13:42:25 -0700 (PDT)
Message-ID: <20130626.134225.986538495628136526.davem@davemloft.net>
References: <1372261233-19648-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843Ab3FZUmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 16:42:25 -0400
In-Reply-To: <1372261233-19648-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 26 Jun 2013 17:40:33 +0200

> Since commit 32b8a8e59c9c "sit: add IPv4 over IPv4 support",
> tunnel->parms.iph.protocol is 0 when both 4in4 and 6in4 are setup, but
> xfrm_lookup() is called only when proto is != 0, thus we need to pass the real
> value.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
