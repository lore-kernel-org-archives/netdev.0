From: "Gerd v. Egidy" <gerd.von.egidy@intra2net.com>
Subject: Re: [bisected] ICMP fragmentation needed ignored / PMTU discovery broken since 3.19-rc7
Date: Tue, 28 Apr 2015 10:59:42 +0200
Message-ID: <7692136.OjBi0VzJYB@thunder>
References: <20150428034314.GA30299@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, lw@cn.fujitsu.com, davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:44555 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938AbbD1JFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 05:05:12 -0400
In-Reply-To: <20150428034314.GA30299@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Herbert,

> This patch might help:
> 
> ---8<---
> Subject: route: Use ipv4_mtu instead of raw rt_pmtu

thank you very much for looking into this. With your patch applied I was not 
able to reproduce the problem anymore.

Could you take care of getting this into mainline and stable?

Thanks.

Kind regards,

Gerd
