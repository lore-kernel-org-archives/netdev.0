From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: RE: mlx4_en: Fix loss of promiscuity
Date: Sun, 27 Mar 2011 11:21:37 +0000
Message-ID: <953B660C027164448AE903364AC447D20705E115@mtldag01.mtl.com>
References: <20110327110126.GA25595@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:33797 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753263Ab1C0LVp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 07:21:45 -0400
In-Reply-To: <20110327110126.GA25595@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> mlx4_en: Fix loss of promiscuity
> 
> The mlx4_en driver uses the combination stop_port/start_port in a number of places.  Unfortunately that causes any promiscuous mode settings on the hardware to be lost.
> 
> This patch fixes that problem.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 

Thank you Herbert,
This patch does fix the problem you reported on.

Thanks,
Yevgeny
