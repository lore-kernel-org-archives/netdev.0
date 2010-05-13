From: kaber@trash.net
Subject: [PATCH 00/12] netfilter: netfilter update
Date: Thu, 13 May 2010 18:16:13 +0200
Message-ID: <1273767385-18225-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

following is a second netfilter update, containing:

- a compilation fix for ip_tables with CONFIG_NETFILTER_DEBUG=y, from Jan

- a fix for an invalid return value in the multiport match introduced in
  the last series, from Jan

- patches to combine the match and target parameters into a common structure,
  from Jan

- Bart's patch to fix the NULL pointer dereference in bridge netfilter
  reported by Stephen

- minor cleanups and improvements from Jan, Stephen and Joe

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!

Bart De Schuymer (1):
      netfilter: bridge-netfilter: fix crash in br_nf_forward_finish()

Jan Engelhardt (8):
      netfilter: ip_tables: fix compilation when debug is enabled
      netfilter: xtables: fix incorrect return code
      netfilter: xtables: dissolve do_match function
      netfilter: xtables: combine struct xt_match_param and xt_target_param
      netfilter: xtables: substitute temporary defines by final name
      netfilter: xtables: deconstify struct xt_action_param for matches
      netfilter: xtables: change hotdrop pointer to direct modification
      netfilter: xtables: combine built-in extension structs

Joe Perches (1):
      netfilter: remove unnecessary returns from void function()s

Patrick McHardy (1):
      Merge branch 'master' of git://dev.medozas.de/linux

Stephen Hemminger (2):
      netfilter: change NF_ASSERT to WARN_ON
      netfilter: cleanup printk messages

