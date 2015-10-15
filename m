From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/3 iproute2] Lightweight tunnels
Date: Thu, 15 Oct 2015 13:13:37 +0200
Message-ID: <cover.1444907416.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	jbenc@redhat.com, mengke.liu@intel.com, tom@herbertland.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45919 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbbJOLNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 07:13:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roopa Prabhu (3):
  libnetlink: introduce rta_nest and u8,u16,u64 helpers for nesting
    within rtattr
  lwtunnel: Add encapsulation support to ip route
  ip-route man: add usage and description for lwtunnel encap attributes

 include/libnetlink.h   |  10 +++
 include/utils.h        |   3 +
 ip/Makefile            |   2 +-
 ip/iproute.c           |  39 +++++++--
 ip/iproute_lwtunnel.c  | 228 +++++++++++++++++++++++++++++++++++++++++++++++++
 ip/iproute_lwtunnel.h  |   8 ++
 lib/libnetlink.c       |  31 +++++++
 man/man8/ip-route.8.in |  70 ++++++++++++++-
 8 files changed, 384 insertions(+), 7 deletions(-)
 create mode 100644 ip/iproute_lwtunnel.c
 create mode 100644 ip/iproute_lwtunnel.h

-- 
2.4.3
