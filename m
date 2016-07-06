From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC iproute2 0/3] iptunnel: support MPLS in IPv4 and UDP
Date: Wed,  6 Jul 2016 20:23:15 +0200
Message-ID: <1467829398-4601-1-git-send-email-simon.horman@netronome.com>
Cc: stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37924 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755612AbcGFSXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 14:23:31 -0400
Received: by mail-wm0-f49.google.com with SMTP id r201so3517462wme.1
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 11:23:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This short series provides support for MPLS in IPv4 (RFC4023), and by
virtue of FOU MPLS in UDP (RFC7510).

The changes are as follows:
1. Document the mode parameter of SIT tunnels
2. Enhance ipip and sit to handle MPLS. Both already handle IPv4.
   sit also already handles IPv6.

A corresponding kernel patchset will also be posted.

Simon Horman (3):
  iptunnel: document mode parameter for sit tunnels
  iptunnel: add support for mpls/ip to sit tunnels
  iptunnel: add support for mpls/ip to ipip tunnels

 ip/link_iptnl.c       | 47 ++++++++++++++++++++++++++++++++++++++---------
 ip/tunnel.c           | 10 ++++++++++
 man/man8/ip-link.8.in | 10 ++++++++++
 3 files changed, 58 insertions(+), 9 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
