From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] ipv6: prevent race between address creation and removal
Date: Thu,  1 Aug 2013 10:41:26 +0200
Message-ID: <1375346488-1001-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jbenc@redhat.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:44638 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937Ab3HAIlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 04:41:32 -0400
Received: by mail-wi0-f177.google.com with SMTP id hq12so1545265wib.16
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 01:41:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Benc (1):
  ipv6: prevent race between address creation and removal

Jiri Pirko (1):
  ipv6: move peer_addr init into ipv6_add_addr()

 net/ipv6/addrconf.c | 43 ++++++++++++++++++++++---------------------
 1 file changed, 22 insertions(+), 21 deletions(-)

-- 
1.7.11.7
