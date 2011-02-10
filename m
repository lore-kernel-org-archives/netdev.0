From: Ian Molton <ian.molton@collabora.co.uk>
Subject: [RFD][PATCH] Add JMEMCMP to Berkeley Packet Filters
Date: Thu, 10 Feb 2011 12:31:06 +0000
Message-ID: <1297341067-12264-1-git-send-email-ian.molton@collabora.co.uk>
Cc: rdunlap@xenotime.net, isdn@linux-pingi.de, paulus@samba.org,
	arnd@arndb.de, davem@davemloft.net, herbert@gondor.apana.org.au,
	ebiederm@xmission.com, alban.crequy@collabora.co.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:44253 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041Ab1BJMb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 07:31:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 Documentation/networking/filter.txt |    9 ++
 drivers/isdn/i4l/isdn_ppp.c         |    2 
 drivers/net/ppp_generic.c           |    2 
 include/asm-generic/socket.h        |    2 
 include/linux/filter.h              |   17 ++++-
 include/linux/ptp_classify.h        |    2 
 net/core/filter.c                   |  115 ++++++++++++++++++++++++++++++++++--
 net/core/sock.c                     |   14 ++++
 net/core/timestamping.c             |    4 -
 net/packet/af_packet.c              |    3 

This patch adds support for adding a data section to BPF. It is intended to be
used by the JMEMCMP instruction also added in this patch.

There are some issues, mostly noted int he commit message, and I'd like to
check that sk_run_filter() does not get called from a context that cannot sleep
(I dont think so).

Comments welcome!

-Ian
