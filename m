From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/5] ethtool: Decode PORT_OTHER
Date: Thu, 30 Apr 2009 13:37:14 +0100
Message-ID: <1241095034.3185.8.camel@achroite>
References: <1241094796.3185.2.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:35070 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760880AbZD3MhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 08:37:16 -0400
In-Reply-To: <1241094796.3185.2.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 5c45b2d..08165eb 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -941,6 +941,9 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 	case PORT_FIBRE:
 		fprintf(stdout, "FIBRE\n");
 		break;
+	case PORT_OTHER:
+		fprintf(stdout, "Other\n");
+		break;
 	default:
 		fprintf(stdout, "Unknown! (%i)\n", ep->port);
 		break;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

