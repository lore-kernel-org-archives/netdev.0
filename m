From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH iproute2] ss: Report MSS from internal TCP information
Date: Mon, 30 Jul 2012 20:51:07 +0100
Message-ID: <1343677867.2667.33.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46836 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754257Ab2G3TvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 15:51:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 misc/ss.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index cf529ef..8ad830b 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1392,6 +1392,8 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
 			       (double)info->tcpi_rttvar/1000);
 		if (info->tcpi_ato)
 			printf(" ato:%g", (double)info->tcpi_ato/1000);
+		if (info->tcpi_snd_mss)
+			printf(" mss:%d", info->tcpi_snd_mss);
 		if (info->tcpi_snd_cwnd != 2)
 			printf(" cwnd:%d", info->tcpi_snd_cwnd);
 		if (info->tcpi_snd_ssthresh < 0xFFFF)
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
