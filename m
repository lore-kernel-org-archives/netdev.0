From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCHES 0/7]: DCCP patches for 2.6.25
Date: Thu,  6 Dec 2007 19:02:47 -0200
Message-ID: <1196974974-31531-1-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:60129 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbXLFVGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 16:06:12 -0500
Received: by an-out-0708.google.com with SMTP id d31so98171and
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2007 13:06:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

Best Regards,

- Arnaldo

 b/net/dccp/ccids/Kconfig              |   13 
 b/net/dccp/ccids/ccid3.c              |   35 --
 b/net/dccp/ccids/ccid3.h              |   14 
 b/net/dccp/ccids/lib/Makefile         |    2 
 b/net/dccp/ccids/lib/loss_interval.c  |   14 
 b/net/dccp/ccids/lib/packet_history.c |   27 -
 b/net/dccp/ccids/lib/packet_history.h |    3 
 b/net/dccp/ccids/lib/tfrc.c           |   48 +++
 b/net/dccp/ccids/lib/tfrc.h           |   18 -
 b/net/dccp/dccp.h                     |   13 
 net/dccp/ccids/ccid3.c                |  322 ++++++++--------------
 net/dccp/ccids/lib/loss_interval.c    |   13 
 net/dccp/ccids/lib/packet_history.c   |  496 +++++++++++++++++++---------------
 net/dccp/ccids/lib/packet_history.h   |  177 ++++--------
 14 files changed, 579 insertions(+), 616 deletions(-)
