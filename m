From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: [PATCH 0/1] Make netns available for ematch extensions
Date: Wed, 11 Sep 2013 15:20:13 +0200
Message-ID: <1378905614-29691-1-git-send-email-kadlec@blackhole.kfki.hu>
Cc: netdev@vger.kernel.org, "V. Lavrov" <lve@guap.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.kfki.hu ([148.6.0.28]:33556 "EHLO smtp2.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753320Ab3IKNUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Sep 2013 09:20:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

ipset needs netns support and ipset is supported as an ematch extension.
However netns data is not available for ematch extensions. In the next
patch I tried to find the less obtrusive way to pass the required data
to the extensions. Please consider applying it to net-next.

Best regards,
Jozsef

Jozsef Kadlecsik (1):
  net: sched: Make netns available for ematch extensions

 include/net/sch_generic.h |    1 +
 net/sched/cls_api.c       |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)
