From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 00/18] netfilter: IPv6 NAT
Date: Mon, 20 Aug 2012 05:39:48 +0200
Message-ID: <1345434006-16549-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Following is the latest IPv6 NAT patchset, based on -rc2.

Changes since the last posting include:

- removal of fixes already merged into nf-2.6, not included upstream
  yet though, IPv6 SIP will not work

- missing module alias for ip6t_DNAT/ip6t_SNAT added to xt_nat

- compilation fix for ip6t_MASQUERADE without ipt_MASQUERADE enabled

- proper handling of untracked packets in IPv6 fragmentation improvements

- byteorder fixes in IPv6 fragment handling

- conversion to use a mutex for NAT L3/L4 protocol registration

- missing memory barrier before publishing L4 protocol array

- proper cleanup of NATed connections after NAT L3/L4 protocol unregistration

- proper locking (RTNL) for walking network namespaces in NAT cleanup

- only free NAT L4 protocol array at shutdown instead of during L3 protocol
  unregistation, otherwise non built-in protocols are missing after L3
  protocol reload

- endianess annotation fixes

- missing netlink policy for IPv6 NAT attributes

I'll also push these patches to github, but it is currently acting up,
once it works again they'll be available at

git://github.com/kaber/nf-nat-ipv6.git master

