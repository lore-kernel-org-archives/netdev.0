From: Manish Kurup <kurup.manish@gmail.com>
Subject: [PATCH net-next v2 0/2] Completed requested changes
Date: Fri, 27 Oct 2017 16:46:56 -0400
Message-ID: <1509137216-15275-1-git-send-email-manish.kurup@verizon.com>
Cc: aring@mojatatu.com, mrv@mojatatu.com, kurup.manish@gmail.com,
        Manish Kurup <manish.kurup@verizon.com>
To: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:57277 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932307AbdJ0UrX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 16:47:23 -0400
Received: by mail-qt0-f193.google.com with SMTP id z28so9943509qtz.13
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 13:47:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

Apologies for the resend (newbie mistakes), but I made the following
corrections to the cover letter and patches:
* Added version and comment info to subjects of patches and all the changes
  (below). I used v2, since my earlier mails had no versions.
* Added ACKs from Jamal and Jiri to all patches and this cover letter

I've made all requested changes to the act_vlan TC action, tested them, and
here's the new changeset. Thanks a lot!

Here're the changes:
v2: Fixed all helper functions to use RCU (rtnl_dereference) - Eric, Jamal
v2: Fixed indentation, extra line nits - Jamal, Jiri
v2: Moved rcu_head to the end of the struct - Jiri
v2: Re-formatted locals to reverse-christmas-tree - Jiri
v2: Removed mismatched spin_lock() - Cong
v2: Removed spin_lock_bh() in tcf_vlan_init, rtnl_dereference() should
    suffice - Cong, Jiri

Thanks for all the comments!
 
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Manish Kurup <manish.kurup@verizon.com>

Manish Kurup (2):
  net sched act_vlan: Change stats update to use per-core stats
  net sched act_vlan: VLAN action rewrite to use RCU lock/unlock and
    update

 include/net/tc_act/tc_vlan.h | 46 ++++++++++++++++++++++------
 net/sched/act_vlan.c         | 71 ++++++++++++++++++++++++++++----------------
 2 files changed, 82 insertions(+), 35 deletions(-)

-- 
2.7.4
