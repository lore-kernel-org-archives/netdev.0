From: jamal <hadi@cyberus.ca>
Subject: [PATCHES] cleanup skb_clone
Date: Sun, 21 Oct 2007 15:16:55 -0400
Message-ID: <1192994215.4422.13.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:7261 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430AbXJUTRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 15:17:00 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1131785wxd
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2007 12:16:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This a re-submission with the last patch fixed up. Three patches to
follow:
1) Introduces skb_act_clone
2) Uses skb_act_clone
3) documents expected behavior of actions in case of cloning or copying
skbs.

cheers,
jamal

