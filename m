From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 0/2] Use one func to output stats from Netlink and /proc
Date: Tue, 30 Dec 2014 01:56:18 +0200
Message-ID: <1419897380-21012-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:61261 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbaL3AGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 19:06:34 -0500
Received: by mail-la0-f43.google.com with SMTP id s18so11870972lam.2
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 16:06:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactoring to use one func to output sock stats
from Netlink and /proc for unix and packet socket types.

I did some testing but I might miss some cases, would be good if someone
can test it too.

Vadim Kochan (2):
  ss: Unify unix stats output from netlink and proc
  ss: Unify packet stats output from netlink and proc

 misc/ss.c | 310 ++++++++++++++++++++++++++------------------------------------
 1 file changed, 132 insertions(+), 178 deletions(-)

-- 
2.1.3
