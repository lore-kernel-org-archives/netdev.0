From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 0/7] Refactor some internal library functions
Date: Sun, 27 Mar 2016 10:38:23 -0700
Message-ID: <20160327103823.1ffebed4@xeon-e3>
References: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:30599 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751138AbcC0RiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 13:38:10 -0400
In-Reply-To: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Mar 2016 19:35:12 +0100
Phil Sutter <phil@nwl.cc> wrote:

> The following series is a result of reviewing color output support and
> some formatting helpers usually used with struct rtattr fields.
> 
> Phil Sutter (7):
>   color: introduce color helpers and COLOR_CLEAR
>   ipaddress: colorize peer, broadcast and anycast addresses as well
>   make format_host non-reentrant by default
>   utils: make rt_addr_n2a() non-reentrant by default
>   lib/utils: introduce format_host_rta()
>   lib/utils: introduce rt_addr_n2a_rta()
>   lib/ll_addr: improve ll_addr_n2a() a bit
> 
>  bridge/fdb.c          |  4 +--
>  include/color.h       |  5 ++-
>  include/utils.h       | 10 ++++--
>  ip/ip6tunnel.c        |  4 +--
>  ip/ipaddress.c        | 87 ++++++++++++++++++---------------------------------
>  ip/ipaddrlabel.c      |  7 ++---
>  ip/iplink_bond.c      |  7 +----
>  ip/iplink_geneve.c    |  5 ++-
>  ip/iplink_vxlan.c     | 13 ++++----
>  ip/ipmaddr.c          |  6 +---
>  ip/ipmroute.c         | 11 ++-----
>  ip/ipneigh.c          |  6 +---
>  ip/ipprefix.c         | 17 ++--------
>  ip/iproute.c          | 68 ++++++++++++----------------------------
>  ip/iproute_lwtunnel.c | 29 ++++-------------
>  ip/iprule.c           | 39 +++++++----------------
>  ip/iptoken.c          | 11 ++-----
>  ip/iptunnel.c         |  8 ++---
>  ip/ipxfrm.c           | 29 ++++-------------
>  ip/link_gre.c         |  5 ++-
>  ip/link_gre6.c        |  5 ++-
>  ip/link_ip6tnl.c      | 11 ++-----
>  ip/link_iptnl.c       |  7 ++---
>  ip/link_vti.c         |  5 ++-
>  ip/link_vti6.c        |  5 ++-
>  ip/tcp_metrics.c      |  6 ++--
>  ip/xfrm_monitor.c     | 16 ++--------
>  lib/color.c           | 30 +++++++++++++++++-
>  lib/ll_addr.c         | 15 ++-------
>  lib/utils.c           | 20 ++++++++++--
>  misc/ss.c             |  4 +--
>  tc/f_flower.c         | 11 ++-----
>  tc/m_nat.c            |  4 +--
>  33 files changed, 187 insertions(+), 323 deletions(-)
> 

Applied thanks
