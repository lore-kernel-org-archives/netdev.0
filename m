From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH next 0/2] improvements to SSN and TSN handling
Date: Tue, 20 Sep 2016 18:19:12 -0300
Message-ID: <cover.1474405559.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45064 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752931AbcITVTV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 17:19:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch fixes a potential issue made visible by the second one
noticed by David Laight and is a preparation for the next one.

The second patch changes how SSN, TSN and ASCONF serials are compared so
they can use typecheck() and are more like time_before() macro.

Marcelo Ricardo Leitner (2):
  sctp: fix the handling of SACK Gap Ack blocks
  sctp: improve how SSN, TSN and ASCONF serial are compared

 include/net/sctp/sm.h | 94 ++++++++++-----------------------------------------
 net/sctp/outqueue.c   | 11 +++---
 2 files changed, 24 insertions(+), 81 deletions(-)

-- 
2.7.4
