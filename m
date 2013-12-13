From: Fan Du <fan.du@windriver.com>
Subject: [PATCH 0/2] iptables: IPv4/v6 IPcomp match support
Date: Fri, 13 Dec 2013 20:18:40 +0800
Message-ID: <1386937122-30453-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netfilter-devel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patchset provides user with simple commands to set ACTONs
for IPcomp flow. This feature needs a kernel modules ipt_comp
and ip6t_comp to be installed first.

Fan Du (2):
  iptables: Add IPv4 IPcomp match support
  iptables: Add IPv6 IPcomp match support

 extensions/libip6t_ipcomp.c              |  115 +++++++++++++++++++++++++++++
 extensions/libip6t_ipcomp.man            |    7 ++
 extensions/libipt_ipcomp.c               |  116 ++++++++++++++++++++++++++++++
 extensions/libipt_ipcomp.man             |    7 ++
 include/linux/netfilter_ipv4/ipt_comp.h  |   18 +++++
 include/linux/netfilter_ipv6/ip6t_comp.h |   18 +++++
 6 files changed, 281 insertions(+)
 create mode 100644 extensions/libip6t_ipcomp.c
 create mode 100644 extensions/libip6t_ipcomp.man
 create mode 100644 extensions/libipt_ipcomp.c
 create mode 100644 extensions/libipt_ipcomp.man
 create mode 100644 include/linux/netfilter_ipv4/ipt_comp.h
 create mode 100644 include/linux/netfilter_ipv6/ip6t_comp.h

-- 
1.7.9.5

