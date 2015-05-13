From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V9 0/2] openvswitch: Add support for 802.1AD
Date: Tue, 12 May 2015 20:06:34 -0400
Message-ID: <1431475596-16780-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, ccp@atcnet.net, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:33077 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933877AbbEMAGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 20:06:55 -0400
Received: by qgdy78 with SMTP id y78so13478995qgd.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 17:06:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for 802.1AD to the openvswitch kernel module.

V9 includes changes suggested by reviewers

Although the Open Flow specification specified support for 802.1AD (qinq)
as well as push and pop vlan headers,  So far Open vSwitch has only
supported a single tag header.

This patch accompanies version 7 of the patch submitted to openvswitch
dev list.

For discussion, history  and previous versions, of the kernel patch,
see the OVS dev mailing list, openvswitch.org/pipermail/dev/..

Thomas F Herbert (2):
  openvswitch: 802.1ad uapi changes
  Flow handling, actions, and parsing

 include/uapi/linux/openvswitch.h |  17 ++--
 net/openvswitch/flow.c           |  82 ++++++++++++---
 net/openvswitch/flow.h           |   3 +
 net/openvswitch/flow_netlink.c   | 212 +++++++++++++++++++++++++++++++++------
 4 files changed, 265 insertions(+), 49 deletions(-)

-- 
2.1.0
