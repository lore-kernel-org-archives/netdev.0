From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/5] bridge: implement rtnl_link options for getting and setting bridge options
Date: Fri,  5 Sep 2014 15:51:27 +0200
Message-ID: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	sfeldma@cumulusnetworks.com, arvid.brodin@alten.se,
	sucheta.chakraborty@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36430 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050AbaIENvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 09:51:39 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so870502wib.15
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 06:51:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far, only sysfs is complete interface for getting and setting bridge
options. This patchset follows-up on the similar bonding code and
allows userspace to get/set bridge master/port options using Netlink
IFLA_INFO_DATA/IFLA_INFO_SLAVE_DATA attr.

Jiri Pirko (5):
  bridge: switch order of rx_handler reg and upper dev link
  bridge: implement rtnl_link_ops->get_slave_size and
    rtnl_link_ops->fill_slave_info
  bridge: implement rtnl_link_ops->slave_changelink
  bridge: implement rtnl_link_ops->get_size and rtnl_link_ops->fill_info
  bridge: implement rtnl_link_ops->changelink

 include/uapi/linux/if_link.h |  12 +++++
 net/bridge/br_if.c           |  15 +++---
 net/bridge/br_netlink.c      | 109 +++++++++++++++++++++++++++++++++++++++----
 3 files changed, 121 insertions(+), 15 deletions(-)

-- 
1.9.3
