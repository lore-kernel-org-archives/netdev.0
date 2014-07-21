From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net] IPVS fix pull request
Date: Mon, 21 Jul 2014 14:15:07 +0200
Message-ID: <1405944908-4487-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Via Simon Horman, I received the following one-liner for your net tree:

1) Fix crash when exiting from netns that uses IPVS and conntrack,
   from Julian Anastasov via Simon Horman.

You can pull this change from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit ce355e209feb030945dae4c358c02f29a84f3f8b:

  netfilter: nf_tables: 64bit stats need some extra synchronization (2014-07-14 12:00:17 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 2627b7e15c5064ddd5e578e4efd948d48d531a3f:

  ipvs: avoid netns exit crash on ip_vs_conn_drop_conntrack (2014-07-16 09:39:28 +0900)

----------------------------------------------------------------
Julian Anastasov (1):
      ipvs: avoid netns exit crash on ip_vs_conn_drop_conntrack

 net/netfilter/ipvs/ip_vs_conn.c |    1 -
 1 file changed, 1 deletion(-)
