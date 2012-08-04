From: Jan Ariyasu <jan.ariyasu@gmail.com>
Subject: [PATCH 00/13] SCTP: Enable netns
Date: Sat,  4 Aug 2012 15:30:37 -0600
Message-ID: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com>
Cc: Jan Ariyasu <jan.ariyasu@hp.com>
To: Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:62429 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453Ab2HDVbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 17:31:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following set of patches enable network-namespaces for the SCTP protocol.

The multitude of global parameters are stored in a net_generic
structure, and the bulk of the patches enable the protocol to access
the parameters on a per-namespace basis.  The first five patches
enable netns handling of the protocol, procfs and sysfs.

Signed-off-by: Jan Ariyasu <jan.ariyasu@hp.com>
---
