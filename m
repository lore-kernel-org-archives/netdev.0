From: kaber@trash.net
Subject: [PATCH 0/6] netfilter: netfilter fixes
Date: Wed, 22 Sep 2010 09:17:28 +0200
Message-ID: <1285139854-11827-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

the following patches against net-2.6.git fix a few netfilter problems:

- tproxy is not properly handling time-wait sockets, from Eric

- a fix for use of an uninitizalized variable in the TCP SIP tracking,
  from Simon

- a fix for TCP RST routing with bridges, from Changli

- a fix for a RCU race in nf_ct_ext_create(), from Eric

- a checksum calculation fix for the SNMP NAT helper, from myself,
  based on a patch from Clark Weng and Stephen

- a fix for incorrectly skipped conntrack defragmentation with the tun
  driver. from Jiri Olsa

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!
