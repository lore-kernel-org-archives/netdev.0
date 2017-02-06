From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next/iproute 0/5] tc: bash-completion: Add features
Date: Mon,  6 Feb 2017 15:19:19 +0200
Message-ID: <1486387164-40404-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org,
        eladr@mellanox.com, idosch@mellanox.com, jiri@mellanox.com,
        jhs@mojatatu.com, mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51770 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751154AbdBFNQu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 08:16:50 -0500
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
