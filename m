From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/4] net: allow to change carrier from userspace
Date: Wed, 12 Dec 2012 11:58:03 +0100
Message-ID: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com, shemminger@vyatta.com,
	greearb@candelatech.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:56921 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632Ab2LLK6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 05:58:14 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so178084eaa.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 02:58:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is basically a repost of my previous patchset:
"[patch net-next-2.6 0/2] net: allow to change carrier via sysfs" from Aug 30

The way net-sysfs stores values changed and this patchset reflects it.
Also, I exposed carrier via rtnetlink iface.

So far, only dummy driver uses carrier change ndo. In very near future
team driver will use that as well.

Jiri Pirko (4):
  net: add change_carrier netdev op
  net: allow to change carrier via sysfs
  rtnl: expose carrier value with possibility to set it
  dummy: implement carrier change

 drivers/net/dummy.c          | 10 ++++++++++
 include/linux/netdevice.h    |  7 +++++++
 include/uapi/linux/if_link.h |  1 +
 net/core/dev.c               | 19 +++++++++++++++++++
 net/core/net-sysfs.c         | 15 ++++++++++++++-
 net/core/rtnetlink.c         | 10 ++++++++++
 6 files changed, 61 insertions(+), 1 deletion(-)

-- 
1.8.0
