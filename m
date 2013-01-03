From: Rami Rosen <ramirose@gmail.com>
Subject: [RFC PATCH net-next 0/3] Remove NETIF_F_NETNS_LOCAL from software devices.
Date: Thu,  3 Jan 2013 11:25:18 +0200
Message-ID: <1357205121-4700-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	shemminger@vyatta.com, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:33300 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab3ACJ0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 04:26:31 -0500
Received: by mail-ee0-f43.google.com with SMTP id e49so7483407eek.16
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2013 01:26:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When NETIF_F_NETNS_LOCAL feature is set in some network device,  
we do not allow this device to be moved from one network namespace 
to another (see dev_change_net_namespace()). Vlan device is not considered 
a local device and does not have the NETIF_F_NETNS_LOCAL feature. There is no 
reason that software devices like vxlan, ppp and bridge, will set the
NETIF_F_NETNS_LOCAL feature. This patchset removes NETIF_F_NETNS_LOCAL
from vxlan, ppp and bridge devices.

Rami Rosen (3):
  ppp: remove NETIF_F_NETNS_LOCAL from ppp device features.
  bridge: remove NETIF_F_NETNS_LOCAL from bridge device.
  vxlan: remove NETIF_F_NETNS_LOCAL from vxlan device features.

 drivers/net/ppp/ppp_generic.c | 1 -
 drivers/net/vxlan.c           | 1 -
 net/bridge/br_device.c        | 2 +-
 3 files changed, 1 insertion(+), 3 deletions(-)

-- 
1.7.11.7
