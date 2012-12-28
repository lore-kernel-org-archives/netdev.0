From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next V3,repost 0/4] net: allow to change carrier from userspace
Date: Fri, 28 Dec 2012 10:49:36 +0100
Message-ID: <1356688180-3549-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com, shemminger@vyatta.com,
	greearb@candelatech.com, fbl@redhat.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:62450 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab2L1Jtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 04:49:49 -0500
Received: by mail-ee0-f42.google.com with SMTP id c41so4998438eek.15
        for <netdev@vger.kernel.org>; Fri, 28 Dec 2012 01:49:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is basically a V3 of a repost of my previous patchset:
"[patch net-next-2.6 0/2] net: allow to change carrier via sysfs" from Aug 30

The way net-sysfs stores values changed and this patchset reflects it.
Also, I exposed carrier via rtnetlink iface.

So far, only dummy driver uses carrier change ndo. In very near future
team driver will use that as well.

V2->V3:
 - updated ndo_change_carrier comment by Dan Williams

V1->v2:
 - added bigger comment to ndo and also note to operstate.txt documentation
   stating the clear purpose of this iface

Jiri Pirko (4):
  net: add change_carrier netdev op
  net: allow to change carrier via sysfs
  rtnl: expose carrier value with possibility to set it
  dummy: implement carrier change

 Documentation/networking/operstates.txt |  4 ++++
 drivers/net/dummy.c                     | 10 ++++++++++
 include/linux/netdevice.h               | 12 ++++++++++++
 include/uapi/linux/if_link.h            |  1 +
 net/core/dev.c                          | 19 +++++++++++++++++++
 net/core/net-sysfs.c                    | 15 ++++++++++++++-
 net/core/rtnetlink.c                    | 10 ++++++++++
 7 files changed, 70 insertions(+), 1 deletion(-)

-- 
1.8.0
