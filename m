From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 0/2] ss: Filtering fixes for unix & netlink socks
Date: Sun, 22 Feb 2015 22:23:09 +0200
Message-ID: <1424636591-19903-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:40039 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbbBVUe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2015 15:34:28 -0500
Received: by labgd6 with SMTP id gd6so14876904lab.7
        for <netdev@vger.kernel.org>; Sun, 22 Feb 2015 12:34:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some fixes when filtering unix & netlink sockets.

Vadim Kochan (2):
  ss: Add filter before printing unix stats from Netlink
  ss: Skip filtered netlink sockets before detailed info

 misc/ss.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

-- 
2.2.2
