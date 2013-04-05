From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] net: ipv4: fix couple of addr lifetime related bugs
Date: Fri,  5 Apr 2013 11:39:37 +0200
Message-ID: <1365154779-4204-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33854 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161098Ab3DEJjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 05:39:44 -0400
Received: by mail-wi0-f175.google.com with SMTP id c10so385342wiw.8
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 02:39:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (2):
  net: ipv4: reset check_lifetime_work after changing lifetime
  net: ipv4: fix schelude while atomic bug in check_lifetime()

 net/ipv4/devinet.c | 60 +++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 44 insertions(+), 16 deletions(-)

-- 
1.8.1.2
