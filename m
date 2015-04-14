From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Subject: [PATCH v3 0/2] iputils ping/ping6: add (non-raw) ICMP socket support
Date: Tue, 14 Apr 2015 17:14:04 +0200
Message-ID: <2533400.J7TS57yqTy@msg-id>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	Vasiliy Kulikov <segooon@gmail.com>,
	Tyler Hicks <tyhicks@canonical.com>, s.mesoraca16@gmail.com,
	netdev@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35357 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932596AbbDNPOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 11:14:11 -0400
Received: by widdi4 with SMTP id di4so117752691wid.0
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 08:14:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V2->V3:
 This patchset is based on the Lorenzo Colitti's one instead of the original by
 Vasiliy Kulikov. This one also support ping6.

Salvatore Mesoraca (2):
  iputils ping/ping6: Add a function to check if a packet is ours
  iputils ping/ping6: add (non-raw) ICMP socket support

 doc/ping.sgml |  5 ++--
 ping.c        | 78 ++++++++++++++++++++++++++++++++++++++++++++++++---------------
 ping6.c       | 84 ++++++++++++++++++++++++++++++++++++++++----------------------------
 ping_common.c |  9 ++++++--
 ping_common.h |  2 ++
 5 files changed, 121 insertions(+), 57 deletions(-)
