From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH iproute2 0/2] xfrm: new command for configuring SPD hash
Date: Thu,  9 Apr 2015 17:39:31 +0200
Message-ID: <1428593973-12780-1-git-send-email-christophe.gouault@6wind.com>
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:34047 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830AbbDIPjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 11:39:43 -0400
Received: by widjs5 with SMTP id js5so58026242wid.1
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 08:39:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new command to configure the SPD hash table:
   ip xfrm policy set [ hthresh4 LBITS RBITS ] [ hthresh6 LBITS RBITS ]

and code to display the SPD hash configuration:
   ip -s -s xfrm policy count

The second path updates ip xfrm man page.

Best Regards,
Christophe
--
 ip/xfrm_policy.c   |  105 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip-xfrm.8 |   61 ++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 161 insertions(+), 5 deletions(-)
