From: =?UTF-8?q?J=CE=B5an=20Sacren?= <sakiwit@gmail.com>
Subject: [PATCH net-next 0/3] Trivial fix-ups for openvswitch
Date: Sat,  9 Jan 2016 16:07:08 -0700
Message-ID: <1452380831-11258-1-git-send-email-sakiwit@gmail.com>
Cc: Pravin Shelar <pshelar@nicira.com>, dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34036 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756247AbcAIXHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 18:07:48 -0500
Received: by mail-pa0-f68.google.com with SMTP id yy13so23033358pab.1
        for <netdev@vger.kernel.org>; Sat, 09 Jan 2016 15:07:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series does trivial fix-ups for openvswitch as follows:

1) Clean up the leftover of the unused function.

2) Fix up the twisted struct geneve_port member name.

3) Update the kernel doc to reflect the changes in struct vport.

Jean Sacren (3):
  openvswitch: clean up unused function
  openvswitch: fix struct geneve_port member name
  openvswitch: update kernel doc for struct vport

 net/openvswitch/vport-geneve.c |  6 +++---
 net/openvswitch/vport.h        | 23 ++---------------------
 2 files changed, 5 insertions(+), 24 deletions(-)
