From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/3] team: couple of patches
Date: Fri,  1 Feb 2013 19:17:23 +0100
Message-ID: <1359742646-1485-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:61467 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753309Ab3BASRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 13:17:33 -0500
Received: by mail-ea0-f182.google.com with SMTP id a12so1862840eaa.27
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 10:17:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do long time in-todo-queue convert of port list netlik messages to multipart
ones. That was needed in order to reorder calls in team_port_del(). That
was needed for correct event send of active port zeroing.

Jiri Pirko (3):
  team: handle sending port list in the same way option list is sent
  team: move netlink event notifiers after team_port_leave()
  team: ab: set active port option as changed when port is leaving

 drivers/net/team/team.c                   | 187 ++++++++++++++++--------------
 drivers/net/team/team_mode_activebackup.c |  13 ++-
 2 files changed, 111 insertions(+), 89 deletions(-)

-- 
1.8.1
