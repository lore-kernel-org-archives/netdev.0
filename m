From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 0/5] sctp: add support for generating stream reconf chunks
Date: Sat,  7 Jan 2017 17:42:57 +0800
Message-ID: <cover.1483781759.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35108 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934680AbdAGJnK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 04:43:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is to add some functions to generate stream reconf chunks,
described in RFC6525 Section 3 and Section 4.

v1->v2:
  - put these into a smaller group.
  - rename some temporary variables in the codes.
  - rename the titles of the commits and improve some changelogs.

Xin Long (5):
  sctp: add a common helper function to generate stream reconf chunk
  sctp: add support for generating stream reconf ssn reset request chunk
  sctp: add support for generating stream reconf ssn/tsn reset request
    chunk
  sctp: add support for generating stream reconf response chunk
  sctp: add support for generating stream reconf add streams request
    chunk

 include/linux/sctp.h       |  68 ++++++++++++
 include/net/sctp/sm.h      |  17 ++-
 include/net/sctp/structs.h |   3 +
 net/sctp/associola.c       |   1 +
 net/sctp/sm_make_chunk.c   | 270 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 358 insertions(+), 1 deletion(-)

-- 
2.1.0
