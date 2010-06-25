From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 2/5] ethtool: Mark show_usage() as noreturn
Date: Fri, 25 Jun 2010 15:48:46 +0100
Message-ID: <1277477326.2094.7.camel@achroite.uk.solarflarecom.com>
References: <1277477027.2094.2.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:11732 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756179Ab0FYOst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 10:48:49 -0400
In-Reply-To: <1277477027.2094.2.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This prevents the next patch from provoking an incorrect warning about
an uninitialised variable.

Ben.

 ethtool.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 8969390..d4bf5a8 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -220,6 +220,8 @@ static struct option {
 };
 

+static void show_usage(int badarg) __attribute__((noreturn));
+
 static void show_usage(int badarg)
 {
 	int i;
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

