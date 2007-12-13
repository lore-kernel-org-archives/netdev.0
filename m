From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCHES 0/12]: DCCP patches for 2.6.25
Date: Thu, 13 Dec 2007 13:05:53 -0200
Message-ID: <1197558365-31134-1-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:3530 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762016AbXLMPGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 10:06:19 -0500
Received: by an-out-0708.google.com with SMTP id d31so185726and.103
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 07:06:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

Best Regards,

- Arnaldo

 Documentation/networking/dccp.txt |    6 +
 include/linux/dccp.h              |   24 ++++++-
 net/dccp/dccp.h                   |   10 ++-
 net/dccp/feat.c                   |   29 ++++----
 net/dccp/feat.h                   |   26 -------
 net/dccp/input.c                  |   28 +++++---
 net/dccp/ipv4.c                   |    8 +-
 net/dccp/ipv6.c                   |    8 +-
 net/dccp/minisocks.c              |   33 +++++----
 net/dccp/options.c                |  126 +++++++++++++++++++++++++-------------
 net/dccp/output.c                 |   21 +++++-
 net/dccp/proto.c                  |   34 +++-------
 12 files changed, 208 insertions(+), 145 deletions(-)
