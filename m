From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v2 0/2] sctp: delay calls to sk_data_ready() as much as possible
Date: Wed,  6 Apr 2016 14:53:11 -0300
Message-ID: <cover.1459952558.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36757 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751722AbcDFRxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 13:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1st patch is a preparation for the 2nd. The idea is to not call
->sk_data_ready() for every data chunk processed while processing
packets but only once before releasing the socket.

v2: patchset re-checked, small changelog fixes

Marcelo Ricardo Leitner (2):
  sctp: compress bit-wide flags to a bitfield on sctp_sock
  sctp: delay calls to sk_data_ready() as much as possible

 include/net/sctp/structs.h | 13 +++++++------
 net/sctp/sm_sideeffect.c   |  5 +++++
 net/sctp/ulpqueue.c        |  4 ++--
 3 files changed, 14 insertions(+), 8 deletions(-)

-- 
2.5.0
