From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v2 0/2] sctp: fix src address selection if using secondary address
Date: Fri, 17 Jul 2015 12:34:16 -0300
Message-ID: <cover.1437145508.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757964AbbGQPe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 11:34:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series improves the way SCTP chooses its src address so that the
choosen one will always belong to the interface being used for output.

v1->v2:
 - split out the refactoring from the fix itself
 - Doing a full reverse routing as in v1 is not necessary. Only looking
   for the interface that has the address and comparing its number is
   enough.

Marcelo Ricardo Leitner (2):
  sctp: reduce indent level on sctp_v4_get_dst
  sctp: fix src address selection if using secondary addresses

 net/sctp/protocol.c | 42 +++++++++++++++++++++++++++---------------
 1 file changed, 27 insertions(+), 15 deletions(-)

-- 
2.4.1
