From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/5] BPF updates
Date: Fri, 23 May 2014 18:43:56 +0200
Message-ID: <1400863441-3711-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56715 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243AbaEWQoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 12:44:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These were still in my queue. Please see individual patches for
details.

I have rebased these on top of current net-next with Andrew's
gcc union fixup [1] applied to avoid dealing with an unnecessary
merge conflict.

Thanks !

 [1] http://patchwork.ozlabs.org/patch/351577/

Daniel Borkmann (5):
  net: filter: remove DL macro
  net: filter: let unattached filters use sock_fprog_kern
  net: filter: doc: add section for BPF test suite
  net: filter: improve test case framework
  net: filter: add test case for jump with holes and ret x variants

 Documentation/networking/filter.txt      |  14 +
 drivers/isdn/i4l/isdn_ppp.c              |   4 +-
 drivers/net/ppp/ppp_generic.c            |   4 +-
 drivers/net/team/team_mode_loadbalance.c |  10 +-
 include/linux/filter.h                   |   5 +-
 lib/test_bpf.c                           | 482 +++++++++++++++++++++----------
 net/core/filter.c                        | 195 +++++++------
 net/core/ptp_classifier.c                |   2 +-
 net/netfilter/xt_bpf.c                   |   5 +-
 net/sched/cls_bpf.c                      |   4 +-
 10 files changed, 457 insertions(+), 268 deletions(-)

-- 
1.7.11.7
