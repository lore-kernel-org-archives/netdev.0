From: kaber@trash.net
Subject: [PATCH 0/8] netfilter: netfilter update for net-next
Date: Thu, 21 Jul 2011 12:17:48 +0200
Message-ID: <1311243476-18236-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

following is a netfilter update for net-next, containing:

- changes to the AUDIT target to log the security context, from Mr Dash Four

- RCUification of nfnetlink and nfnetlink_queue from Eric, raising performance
  fourfold in his tests

- a fix for nfnetlink_queue to make sure packet IDs are monotonic increasing,
  from Eric

- nfnetlink_queue batch verdict support from Florian, increasing performance
  even further

- ipset updates from Jozsef

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!
