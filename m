From: Adrian-Ken Rueegsegger <rueegsegger@swiss-it.ch>
Subject: [RFC PATCH] [XFRM] xfrm_algo: correct usage of RIPEMD-160
Date: Mon,  2 Jun 2008 11:33:08 +0200
Message-ID: <1212399189188-git-send-email-rueegsegger@swiss-it.ch>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes HMAC-RIPEMD-160 usable with IPsec/XFRM. The RIPEMD-160
implementation is currently in the cryptodev-2.6 tree.

Since I have no IPsec test setup the patch has not (yet) been tested with
IPsec and is thus marked as RFC. I will put together a test environment which
will take some time. In the meantime it would be great if somebody who already
has a working IPsec environment could test this patch.

Thanks,
Adrian

