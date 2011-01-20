From: kaber@trash.net
Subject: [PATCH 0/7] netfilter: netfilter fixes for net-next
Date: Thu, 20 Jan 2011 21:22:39 +0100
Message-ID: <1295554966-5263-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the following patches fix a couple of problems in yesterdays netfilter pull,
as well as a few unrelated bugs:

- an inconsistency in rerouting with userspace queueing when using queue
  numbers other than zero, from Florian

- a duplicate member in the xt_connlimit_info struct, from Jan

- a missing include in nf_conntrack_reasm, from Eric

- a linking error with NF_CONNTRACK_TIMESTAMP=n, from myself

- missing linux/types.h includes in netfilter headers after the change
  to use __[us]XX types, from Jan

Additionally a few new features are contained:

- connlimit revision 1, supporting limiting by destination

- NAT fixes for source address selection, from Changli

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!
