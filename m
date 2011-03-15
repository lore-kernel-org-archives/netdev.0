From: kaber@trash.net
Subject: [PATCH 00/37] netfilter: netfilter update
Date: Tue, 15 Mar 2011 20:43:40 +0100
Message-ID: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

[appologies if this reaches you twice, my mail settings were misconfigured]

following is a final netfilter update for net-next, containing:

- a fix for misuse of try_then_request_module(), from Stephen

- a fix for a sysctl memory leak, from Stephen

- IPVS updates from Simon, mainly consisting of exclusion of control code
  when CONFIG_SYSCTL=n

- xt_connlimit cleanups and fixes, from Changli

- conversion of xt_connlimit to hlists, from Changli

- fixes for some information leaks in {ip,ip6,arp}_tables, from Vasiliy Kulikov

- an IPv6 capable version of the addrtype match, from Florian Westphal


Please pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!

