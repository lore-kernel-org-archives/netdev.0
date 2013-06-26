From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 0/2] xfrm/af_key constify patches
Date: Wed, 26 Jun 2013 23:56:57 +0200
Message-ID: <1372283819-30012-1-git-send-email-minipli@googlemail.com>
Cc: Mathias Krause <minipli@googlemail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:60987 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516Ab3FZV5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 17:57:11 -0400
Received: by mail-bk0-f41.google.com with SMTP id jc3so764bkc.0
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 14:57:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

two small patches, constifying af_key lookup tables and a xfrm function
argument. All material for ipsec-next.

Please apply!

Thanks,

Mathias Krause (2):
  xfrm: constify mark argument of xfrm_find_acq()
  af_key: constify lookup tables

 include/net/xfrm.h    |    2 +-
 net/key/af_key.c      |    6 +++---
 net/xfrm/xfrm_state.c |   12 +++++++-----
 3 files changed, 11 insertions(+), 9 deletions(-)

-- 
1.7.10.4
