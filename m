From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v2 0/2] bridge: support for vlan range in setlink/dellink
Date: Wed, 31 Dec 2014 08:48:51 -0800
Message-ID: <1420044533-16963-1-git-send-email-roopa@cumulusnetworks.com>
Cc: sfeldma@gmail.com, wkok@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: netdev@vger.kernel.org, hemminger@vyatta.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:43618 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbaLaQs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 11:48:58 -0500
Received: by mail-pd0-f173.google.com with SMTP id ft15so21149432pdb.4
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 08:48:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This series adds new netlink attribute to represent vlan range.

Will post corresponding iproute2 patches if these get accepted.

v1-> v2
    - changed patches to use a nested list of IFLA_BRIDGE_VLAN_INFO
    as suggested by scott feldman
    - dropped notification changes from the series. Will post them
    separately after this range message is accepted.

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Roopa Prabhu (2):
  bridge: new attribute and flags to represent vlan info lists and
    ranges
  bridge: modify bridge af spec parser to accomodate vlan list and
    ranges

 include/uapi/linux/if_bridge.h |    4 ++
 net/bridge/br_netlink.c        |  118 ++++++++++++++++++++++++++++++----------
 2 files changed, 92 insertions(+), 30 deletions(-)

-- 
1.7.10.4
