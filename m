From: Ihar Hrachyshka <ihrachys@redhat.com>
Subject: [PATCH 0/2] arp: always override existing neigh entries with gratuitous ARP
Date: Wed, 17 May 2017 14:33:05 -0700
Message-ID: <cover.1495056542.git.ihrachys@redhat.com>
Cc: Ihar Hrachyshka <ihrachys@redhat.com>, netdev@vger.kernel.org
To: davem@davemloft.net, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36870 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752832AbdEQVdc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 17:33:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good day.

This patchset is spurred by discussion started at
https://patchwork.ozlabs.org/patch/760372/ where we figured that there is no
real reason for enforcing override by gratuitous ARP packets only when
arp_accept is 1. Same should happen when it's 0 (the default value).

The first patch in the series moves is_garp code into a separate function
preparing the code base for the 2nd patch that actually implements the needed
change.

Ihar Hrachyshka (2):
  arp: decompose is_garp logic into a separate function
  arp: always override existing neigh entries with gratuitous ARP

 net/ipv4/arp.c | 47 +++++++++++++++++++++++++++++------------------
 1 file changed, 29 insertions(+), 18 deletions(-)

-- 
2.9.3
