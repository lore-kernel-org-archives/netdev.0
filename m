From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 0/2] irda: GFP_ATOMIC cleanups
Date: Fri,  5 Apr 2013 22:41:26 +0200
Message-ID: <1365194488-23462-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f48.google.com ([209.85.214.48]:39034 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162519Ab3DEUls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 16:41:48 -0400
Received: by mail-bk0-f48.google.com with SMTP id jf3so2272757bkc.21
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 13:41:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Samuel, Dave,

this small series changes some obvious misusages of GFP_ATOMIC in the
irda code.

Please apply -- probably to net-next!


Mathias Krause (2):
  irda: use GFP_KERNEL in irda_create()
  irda: use GFP_KERNEL in irda_connect_response()

 net/irda/af_irda.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

-- 
1.7.10.4
