From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 14/21] Fix reference to cmdline_ring in
 do_schannels()
Date: Tue, 1 Nov 2011 23:18:54 +0000
Message-ID: <1320189534.2758.44.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38391 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932086Ab1KAXS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:18:58 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cmdline_ring and cmdline_channels have the same array size, so this
just happened to work.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 9d416e1..7bdf173 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1681,7 +1681,7 @@ static int do_schannels(struct cmd_context *ctx)
 	int err, changed = 0;
 
 	parse_generic_cmdline(ctx, &gchannels_changed,
-			      cmdline_channels, ARRAY_SIZE(cmdline_ring));
+			      cmdline_channels, ARRAY_SIZE(cmdline_channels));
 
 	echannels.cmd = ETHTOOL_GCHANNELS;
 	err = send_ioctl(ctx, &echannels);
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
