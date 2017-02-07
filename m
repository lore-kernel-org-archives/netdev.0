From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next/iproute v2 0/5] tc: bash-completion: Add features
Date: Tue,  7 Feb 2017 15:50:47 +0200
Message-ID: <1486475452-39214-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org,
        eladr@mellanox.com, idosch@mellanox.com, jiri@mellanox.com,
        jhs@mojatatu.com, mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38632 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753451AbdBGNsR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 08:48:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first 4 patches add support for autompletion of filter actions, thus
allowing the following tab completions:

$ tc filter add dev eth0 u32 [...] action <TAB>
bpf     gact    mirred  sample

$ tc filter add dev eth0 u32 [...] action sample <TAB>
action  group   rate    trunc

$ tc filter add dev eth0 u32 [...] \
	action sample group 10 rate 10 action mirred <TAB>
action    dev       egress    index     ingress   mirror    redirect

Finally, the last patch adds support in matchall autocompletion.

v1->v2:
 - Rebased on top of net-next tree

Yotam Gigi (5):
  tc: bash-completion: Add the _from variant to _tc_one* funcs
  tc: bash-completion: Prepare action autocomplete to support several
    actions
  tc: bash-completion: Make the *_KIND variables global
  tc: bash-completion: Add support for filter actions
  tc: bash-completion: Add support for matchall

 bash-completion/tc | 121 ++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 96 insertions(+), 25 deletions(-)

-- 
2.4.11
