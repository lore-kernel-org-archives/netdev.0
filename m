From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH iproute2 v4 0/4] add MACsec support
Date: Fri,  3 Jun 2016 16:45:44 +0200
Message-ID: <cover.1464963543.git.sd@queasysnail.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Phil Sutter <phil@nwl.cc>, Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932209AbcFCOqB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2016 10:46:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series introduces support for MACsec devices, with a new device
type for `ip link`, and a new `ip macsec` subcommand.

The first three patches introduce some necessary helper functions.

Sabrina Dubroca (4):
  utils: make hexstring_a2n provide the number of hex digits parsed
  utils: add get_be{16,32,64}, use them where possible
  utils: provide get_hex to read a hex digit from a char
  ip: add MACsec support

 include/utils.h       |    8 +-
 ip/Makefile           |    2 +-
 ip/ip.c               |    3 +-
 ip/ip_common.h        |    1 +
 ip/ipfou.c            |    3 +-
 ip/ipl2tp.c           |   15 +-
 ip/iplink_vxlan.c     |    8 +-
 ip/ipmacsec.c         | 1292 +++++++++++++++++++++++++++++++++++++++++++++++++
 ip/iproute_lwtunnel.c |    8 +-
 ip/ipxfrm.c           |   13 +-
 ip/xfrm_state.c       |   10 +-
 lib/ipx_pton.c        |   18 +-
 lib/ll_proto.c        |    3 +-
 lib/utils.c           |   53 +-
 man/man8/Makefile     |    2 +-
 man/man8/ip-link.8.in |   85 ++++
 man/man8/ip-macsec.8  |   98 ++++
 tc/f_flower.c         |    4 +-
 tc/f_u32.c            |   10 +-
 19 files changed, 1560 insertions(+), 76 deletions(-)
 create mode 100644 ip/ipmacsec.c
 create mode 100644 man/man8/ip-macsec.8

-- 
2.8.3
