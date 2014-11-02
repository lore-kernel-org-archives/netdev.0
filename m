From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/2] tun: Fix csum_start and TUN_PKT_STRIP
Date: Mon, 3 Nov 2014 04:29:30 +0800
Message-ID: <20141102202929.GA24935@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:46620 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbaKBU3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 15:29:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

The first patch fixes a serious problem that breaks checksum offload
in VMs while the second patch fixes a problem that probably affects
no one.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
