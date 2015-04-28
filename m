From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V7 0/2] openvswitch: Add support for 802.1AD
Date: Tue, 28 Apr 2015 18:44:17 -0400
Message-ID: <1430261059-7920-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, ccp@atcnet.net,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vn0-f43.google.com ([209.85.216.43]:41164 "EHLO
	mail-vn0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031075AbbD1Won (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 18:44:43 -0400
Received: by vnbg190 with SMTP id g190so1374939vnb.8
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 15:44:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for 802.1AD to the openvswitch kernel module.

Although the Open Flow specification specified support for 802.1AD (qinq) 
as well as push and pop vlan headers,  So far Open vSwitch has only
supported a single tag header.

This accompanies version 7 of the patch submitted to openvswitch dev list.

For discussion, history  and previous versions, of the kernel patch, 
see the OVS dev mailing list, openvswitch.org/pipermail/dev/..

Thomas F Herbert (2):
  add flow key field for ctag
  Flow handling, actions, and vlan parsing for 8021AD

 include/uapi/linux/openvswitch.h | 17 ++++----
 net/openvswitch/actions.c        |  6 ++-
 net/openvswitch/flow.c           | 83 +++++++++++++++++++++++++++++++++-------
 net/openvswitch/flow.h           |  1 +
 net/openvswitch/flow_netlink.c   | 81 ++++++++++++++++++++++++++++++++++++---
 5 files changed, 160 insertions(+), 28 deletions(-)

-- 
2.1.0
