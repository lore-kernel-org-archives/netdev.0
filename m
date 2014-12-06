From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 0/2] lib names: Refactoring and cleanups
Date: Sat,  6 Dec 2014 04:05:10 +0200
Message-ID: <1417831512-19452-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:46108 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbaLFCO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 21:14:58 -0500
Received: by mail-la0-f49.google.com with SMTP id hs14so1578799lab.22
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 18:14:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some cleanups and refactoring in lib/rt_names.c:

    #1 Replaced using of /etc/iproute2 path by CONFDIR define
        when initializing tables of group names.

    #2 Added helper to have one func for parsing id and names from
        db files.

Vadim Kochan (2):
  lib names: Use CONFDIR for specify 'group' file path
  lib names: Add helper func for parse id and name from file

 lib/rt_names.c | 70 +++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 40 insertions(+), 30 deletions(-)

-- 
2.1.3
