From: Andy Zhou <azhou@ovn.org>
Subject: [RFC net-next sample action optimization 0/3]
Date: Tue,  7 Mar 2017 16:15:34 -0800
Message-ID: <1488932137-120383-1-git-send-email-azhou@ovn.org>
Cc: joe@ovn.org, pshelar@ovn.org, Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34993 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933282AbdCHAYy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 19:24:54 -0500
Received: by mail-pg0-f66.google.com with SMTP id 187so1549575pgb.2
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 16:22:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sample action can be used for translating Openflow 'clone' action.
However its implementation has not been sufficiently optimized for this
use case. This series attempts to close the gap.

Patch 3 commit message has more details on the specific optimizations
implemented.


Andy Zhou (3):
  openvswitch: deferred fifo api change
  openvswitch: Refactor recirc key allocation.
  openvswitch: Optimize sample action for the clone use cases

 net/openvswitch/actions.c      | 190 ++++++++++++++++++++++-------------------
 net/openvswitch/datapath.h     |   7 ++
 net/openvswitch/flow_netlink.c | 118 +++++++++++++++++--------
 3 files changed, 192 insertions(+), 123 deletions(-)

-- 
1.8.3.1
