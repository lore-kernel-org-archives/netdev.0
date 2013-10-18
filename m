From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net REPOST 0/3] UFO fixes
Date: Fri, 18 Oct 2013 19:13:48 +0200
Message-ID: <1382116431-28758-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	hannes@stressinduktion.or, jdmason@kudzu.us,
	yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:32774 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756533Ab3JRRNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 13:13:53 -0400
Received: by mail-ea0-f172.google.com with SMTP id r16so2172458ead.17
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 10:13:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Couple of patches fixing UFO functionality in different situations.

Jiri Pirko (3):
  udp6: respect IPV6_DONTFRAG sockopt in case there are pending frames
  ip6_output: do skb ufo init for peeked non ufo skb as well
  ip_output: do skb ufo init for peeked non ufo skb as well

 net/ipv4/ip_output.c  | 14 +++++++++-----
 net/ipv6/ip6_output.c | 26 ++++++++++++++------------
 net/ipv6/udp.c        |  5 ++---
 3 files changed, 25 insertions(+), 20 deletions(-)

-- 
1.8.3.1
