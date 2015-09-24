From: Karl Heiss <kheiss@gmail.com>
Subject: [PATCH net 0/2] sctp: Fix SCTP deadlock
Date: Thu, 24 Sep 2015 12:15:05 -0400
Message-ID: <1443111307-16503-1-git-send-email-kheiss@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:34883 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbbIXQPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 12:15:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix a deadlock during accept() of an SCTP connection.

The first patch fixes whitespace issues.

The second patch actually fixes the deadlock race.

Karl Heiss (2):
  sctp: Whitespace fix
  sctp: Prevent soft lockup when sctp_accept() is called during a
    timeout event

 net/sctp/sm_sideeffect.c |   44 ++++++++++++++++++++++++--------------------
 1 files changed, 24 insertions(+), 20 deletions(-)
