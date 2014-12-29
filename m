From: roopa@cumulusnetworks.com
Subject: [PATCH 0/6] bridge: suport for vlan range and vlan add/del notifications
Date: Mon, 29 Dec 2014 13:05:26 -0800
Message-ID: <1419887132-7084-1-git-send-email-roopa@cumulusnetworks.com>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33549 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606AbaL2VFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 16:05:41 -0500
Received: by mail-pd0-f169.google.com with SMTP id z10so18090211pdj.0
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 13:05:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This series adds new netlink attribute to represent vlan range.
Enables bridge link notify msgs to send vlan information.

Will post corresponding iproute2 patches if these get accepted.

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Roopa Prabhu (6):
  bridge: add support to parse multiple vlan info attributes in
    IFLA_AF_SPEC
  bridge: add new attribute IFLA_BRIDGE_VLAN_RANGE_INFO to represent
    vlan range
  bridge: modify IFLA_AF_SPEC parser to parse
    IFLA_BRIDGE_VLAN_RANGE_INFO
  rtnetlink: new filter RTEXT_FILTER_BRVLAN_COMPRESSED
  bridge: new function to pack vlans using both IFLA_BRIDGE_VLAN_INFO
    and IFLA_BRIDGE_VLAN_RANGE_INFO
  bridge: add vlan info to bridge setlink and dellink notification
    messages

 include/uapi/linux/if_bridge.h |    7 ++
 include/uapi/linux/rtnetlink.h |    1 +
 net/bridge/br_netlink.c        |  240 ++++++++++++++++++++++++++++++++--------
 net/core/rtnetlink.c           |    3 +-
 4 files changed, 204 insertions(+), 47 deletions(-)

-- 
1.7.10.4
