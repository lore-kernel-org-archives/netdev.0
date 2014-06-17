From: Geir Ola Vaagland <geirola@gmail.com>
Subject: [PATCH net-next 0/6] A step closer to RFC 6458 compliancy
Date: Tue, 17 Jun 2014 13:57:47 +0200
Message-ID: <1403006273-27859-1-git-send-email-geirola@gmail.com>
Cc: linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:46936 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754281AbaFQL57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 07:57:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Geir Ola Vaagland (6):
  Support for SCTP_RECVRCVINFO socket option
  Support for SCTP_RCVINFO ancillary data
  Support for SCTP_SNDINFO ancillary data
  Support for SCTP_NXTINFO socket option
  Support for receiving SCTP_NXTINFO ancillary data
  Support for SCTP_DEFAULT_SNDINFO socket option

 include/net/sctp/structs.h  |  11 +-
 include/net/sctp/ulpevent.h |   4 +
 include/uapi/linux/sctp.h   |  46 ++++++++
 net/sctp/socket.c           | 260 ++++++++++++++++++++++++++++++++++++++++++--
 net/sctp/ulpevent.c         | 158 +++++++++++++++++++++++++++
 5 files changed, 470 insertions(+), 9 deletions(-)
