From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCHES 0/7]: DCCP patches for 2.6.25
Date: Wed, 12 Dec 2007 14:36:46 -0200
Message-ID: <1197477413-1456-1-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:60575 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757042AbXLLQhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 11:37:53 -0500
Received: by an-out-0708.google.com with SMTP id d31so73103and.103
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 08:37:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

Best Regards,

- Arnaldo

 b/net/dccp/ccids/ccid3.c              |    2 
 b/net/dccp/ccids/ccid3.h              |    5 
 b/net/dccp/ccids/lib/loss_interval.c  |  161 ++++++++++++++++++-
 b/net/dccp/ccids/lib/loss_interval.h  |   56 ++++++
 b/net/dccp/ccids/lib/packet_history.c |   68 +++-----
 b/net/dccp/ccids/lib/packet_history.h |   36 ++++
 b/net/dccp/ccids/lib/tfrc.c           |   32 ++-
 b/net/dccp/ccids/lib/tfrc.h           |    4 
 b/net/dccp/dccp.h                     |    8 
 net/dccp/ccids/ccid3.c                |   72 +++++++-
 net/dccp/ccids/ccid3.h                |   10 -
 net/dccp/ccids/lib/loss_interval.c    |  284 +---------------------------------
 net/dccp/ccids/lib/loss_interval.h    |   11 -
 net/dccp/ccids/lib/packet_history.c   |  279 +++++++++++++++++++++++++--------
 net/dccp/ccids/lib/packet_history.h   |   47 ++++-
 net/dccp/ccids/lib/tfrc.c             |   10 -
 16 files changed, 643 insertions(+), 442 deletions(-)
