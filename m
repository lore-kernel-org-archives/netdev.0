From: Ihar Hrachyshka <ihrachys@redhat.com>
Subject: [PATCH v2 0/4] arp: always override existing neigh entries with gratuitous ARP
Date: Thu, 18 May 2017 12:41:17 -0700
Message-ID: <cover.1495136258.git.ihrachys@redhat.com>
Cc: Ihar Hrachyshka <ihrachys@redhat.com>, netdev@vger.kernel.org
To: davem@davemloft.net, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35938 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751782AbdERTle (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 15:41:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is spurred by discussion started at
https://patchwork.ozlabs.org/patch/760372/ where we figured that there is no
real reason for enforcing override by gratuitous ARP packets only when
arp_accept is 1. Same should happen when it's 0 (the default value).

changelog v2: handled review comments by Julian Anastasov
- fixed a mistake in a comment;
- postponed addr_type calculation to as late as possible.

Ihar Hrachyshka (4):
  arp: fixed error in a comment
  arp: decompose is_garp logic into a separate function
  arp: postpone addr_type calculation to as late as possible
  arp: always override existing neigh entries with gratuitous ARP

 net/ipv4/arp.c | 56 +++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 39 insertions(+), 17 deletions(-)

-- 
2.9.3
