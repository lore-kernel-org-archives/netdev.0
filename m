From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next 0/2] netfilter: IPv4/v6 IPcomp match support
Date: Fri, 13 Dec 2013 20:18:00 +0800
Message-ID: <1386937082-30412-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <steffen.klassert@secunet.com>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patchset adds IPv4/v6 IPComp 'match' plugin to enables user setting
ACTONs for IPcomp flows sepecified with SPI value.

Corresponding iptables patchset will be sent here after soon.

Fan Du (2):
  netfilter: add IPv4 IPComp extension match support
  netfilter: add IPv6 IPComp extension match support

 include/uapi/linux/netfilter_ipv4/ipt_comp.h  |   18 ++++
 include/uapi/linux/netfilter_ipv6/ip6t_comp.h |   18 ++++
 net/ipv4/netfilter/Kconfig                    |    9 ++
 net/ipv4/netfilter/Makefile                   |    1 +
 net/ipv4/netfilter/ipt_comp.c                 |  101 +++++++++++++++++++++++
 net/ipv6/netfilter/Kconfig                    |    8 ++
 net/ipv6/netfilter/Makefile                   |    1 +
 net/ipv6/netfilter/ip6t_comp.c                |  110 +++++++++++++++++++++++++
 8 files changed, 266 insertions(+)
 create mode 100644 include/uapi/linux/netfilter_ipv4/ipt_comp.h
 create mode 100644 include/uapi/linux/netfilter_ipv6/ip6t_comp.h
 create mode 100644 net/ipv4/netfilter/ipt_comp.c
 create mode 100644 net/ipv6/netfilter/ip6t_comp.c

-- 
1.7.9.5

