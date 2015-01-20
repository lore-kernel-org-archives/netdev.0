From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH 0/2] Refactoring for meminfo & inet sockets output
Date: Tue, 20 Jan 2015 16:14:22 +0200
Message-ID: <1421763264-8954-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:32970 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbbATOZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 09:25:09 -0500
Received: by mail-we0-f178.google.com with SMTP id p10so37670173wes.9
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 06:25:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

This is just refactoring to have meminfo and inet stats
output in one place.

Vadim Kochan (2):
  ss: Unify meminfo output
  ss: Unify inet sockets output

 misc/ss.c | 707 +++++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 373 insertions(+), 334 deletions(-)

-- 
2.1.3
