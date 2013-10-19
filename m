From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 0/3] UFO fixes
Date: Sat, 19 Oct 2013 12:29:14 +0200
Message-ID: <1382178557-14737-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	hannes@stressinduktion.org, jdmason@kudzu.us,
	yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:39477 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843Ab3JSK3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 06:29:21 -0400
Received: by mail-ee0-f43.google.com with SMTP id e52so2626008eek.30
        for <netdev@vger.kernel.org>; Sat, 19 Oct 2013 03:29:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Couple of patches fixing UFO functionality in different situations.

v1->v2:
- minor if{}else{} coding style adjustment suggested by Sergei Shtylyov

Jiri Pirko (3):
  udp6: respect IPV6_DONTFRAG sockopt in case there are pending frames
  ip6_output: do skb ufo init for peeked non ufo skb as well
  ip_output: do skb ufo init for peeked non ufo skb as well

 net/ipv4/ip_output.c  | 13 +++++++++----
 net/ipv6/ip6_output.c | 25 ++++++++++++++-----------
 net/ipv6/udp.c        |  5 ++---
 3 files changed, 25 insertions(+), 18 deletions(-)

-- 
1.8.3.1
