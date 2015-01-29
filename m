From: Tom Herbert <therbert@google.com>
Subject: [PATCH iproute2 0/4] iproute: Support for remote checksum offload
Date: Thu, 29 Jan 2015 08:51:57 -0800
Message-ID: <1422550321-30901-1-git-send-email-therbert@google.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:49840 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbbA2QxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 11:53:08 -0500
Received: by mail-ie0-f177.google.com with SMTP id vy18so35981857iec.8
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 08:53:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, updated man pages for remote checksum offload options,
and added a section on setting FOU/GUE encapsulation with IP tunnels.

Tom Herbert (4):
  ip link: Add support for remote checksum offload to IP tunnels
  vxlan: Add support for remote checksum offload
  iproute: Description of new options for VXLAN in ip-link man pages
  iproute: Descriptions of fou and gue options in ip-link man pages

 include/linux/if_link.h |  2 ++
 ip/iplink_vxlan.c       | 21 ++++++++++++
 ip/link_gre.c           | 11 ++++++-
 ip/link_iptnl.c         | 11 ++++++-
 man/man8/ip-link.8.in   | 86 ++++++++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 128 insertions(+), 3 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
