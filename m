From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net 0/4] xfrm_user info leaks
Date: Sat, 26 Aug 2017 17:08:56 +0200
Message-ID: <1503760140-9095-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:37437 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750931AbdHZPJ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 11:09:26 -0400
Received: by mail-wm0-f66.google.com with SMTP id r13so173449wmf.4
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2017 08:09:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Steffen,

the following series fixes a few info leaks due to missing padding byte
initialization in the xfrm_user netlink interface.

Please apply!

Mathias Krause (4):
  xfrm_user: fix info leak in copy_user_offload()
  xfrm_user: fix info leak in xfrm_notify_sa()
  xfrm_user: fix info leak in build_expire()
  xfrm_user: fix info leak in build_aevent()

 net/xfrm/xfrm_user.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

-- 
1.7.10.4
