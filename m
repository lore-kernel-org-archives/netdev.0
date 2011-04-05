From: kaber@trash.net
Subject: [PATCH 0/8] netfilter: netfilter fixes for 2.6.39-rc1
Date: Tue,  5 Apr 2011 15:04:11 +0200
Message-ID: <1302008659-21141-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

the following patches for 2.6.39-rc1 fix a few bugs in netfilter:

- ipset list:set timeout variant was broken, from Jozsef

- incorrect locking in ipset, from Jozsef

- incorrect parsing of the amount of elements encoded in SEQUENCE OF for
  numbers between 2^8 and 2^16-1 in the H.323 conntrack ASN.1 parser,
  from David Sterba

- a NULL pointer dereference in ip_vs_genl_dump_daemons(), from Hans

- patches from Florian to avoid pulling in the IPv6 module when loading
  the xt_addrtype module

- an inverted check for inversion in the conntrack direction match,
  from Florian

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!

