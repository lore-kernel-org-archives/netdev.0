From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next 0/4] sctp: add sender-side procedures for stream reconf asoc reset and add streams
Date: Fri, 20 Jan 2017 01:19:10 +0800
Message-ID: <cover.1484845510.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34432 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753887AbdASRTW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 12:19:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 2/4 is to implement sender-side procedures for the SSN/TSN Reset
Request Parameter described in rfc6525 section 5.1.4, patch 1/4 is
ahead of it to define a function to make the request chunk for it.

Patch 4/4 is to implement sender-side procedures for the Add Incoming
and Outgoing Streams Request Parameter Request Parameter described in
rfc6525 section 5.1.5 and 5.1.6, patch 3/4 is ahead of it to define a
function to make the request chunk for it.

v1->v2:
  - put these into a smaller group.
  - rename some temporary variables in the codes.
  - rename the titles of the commits and improve some changelogs.
v2->v3:
  - re-split the patchset and make sure it has no dead codes for review.
  - move some codes into stream.c from socket.c.

Xin Long (4):
  sctp: add support for generating stream reconf ssn/tsn reset request
    chunk
  sctp: implement sender-side procedures for SSN/TSN Reset Request
    Parameter
  sctp: add support for generating stream reconf add incoming/outgoing
    streams request chunk
  sctp: implement sender-side procedures for Add Incoming/Outgoing
    Streams Request Parameter

 include/linux/sctp.h      |  12 +++++
 include/net/sctp/sctp.h   |   3 ++
 include/net/sctp/sm.h     |   5 ++
 include/uapi/linux/sctp.h |   8 +++
 net/sctp/sm_make_chunk.c  |  75 ++++++++++++++++++++++++++
 net/sctp/socket.c         |  58 ++++++++++++++++++++
 net/sctp/stream.c         | 132 ++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 293 insertions(+)

-- 
2.1.0
