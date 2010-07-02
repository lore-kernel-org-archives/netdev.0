From: kaber@trash.net
Subject: [PATCH 0/9] netfilter: netfilter update
Date: Fri,  2 Jul 2010 11:52:13 +0200
Message-ID: <1278064342-19059-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46382 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab0GBJwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 05:52:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following is a small netfilter update for net-next, containing:

- a patch to support user-defined SNAT rules in the nat/INPUT chain,
  from myself

- one-packet scheduling for IPVS from Nick Chalk

- missing kdev_t.h inclusion in xt_IDLETIMER from Randy Dunlap

- the removal of CONFIG_NF_CT_ACCT, originally scheduled for 2.6.29,
  from Tim Gardner

- a patch to support MAC header decoding in the netfilter LOG targets,
  from myself

- a patch for per bridge device controls for iptables invocation, from
  myself


Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!


Arnd Hannemann (1):
      netfilter: fix simple typo in KConfig for netfiltert xt_TEE

Nick Chalk (1):
      IPVS: one-packet scheduling

Patrick McHardy (4):
      netfilter: nf_nat: support user-specified SNAT rules in LOCAL_IN
      netfilter: ipt_LOG/ip6t_LOG: remove comparison within loop
      netfilter: ipt_LOG/ip6t_LOG: add option to print decoded MAC header
      bridge: add per bridge device controls for invoking iptables

Randy Dunlap (1):
      netfilter: xt_IDLETIMER needs kdev_t.h

Tim Gardner (2):
      netfilter: xt_connbytes: Force CT accounting to be enabled
      netfilter: complete the deprecation of CONFIG_NF_CT_ACCT

