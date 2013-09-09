From: Ben Hutchings <bhutchings@solarflare.com>
Subject: bnx2x fix for stable
Date: Mon, 9 Sep 2013 18:50:27 +0100
Message-ID: <1378749027.1806.4.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>,
	Dave Jones <davej@redhat.com>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32018 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab3IIRug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 13:50:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think you need to either drop the bnx2x non-fix currently in your
stable queue (commit c0a77ec74f29 'bnx2x: Add missing braces in
bnx2x:bnx2x_link_initialize', or add the follow-up (commit 937e5c3d63a1
'bnx2x: Restore a call to config_init') with the net result of fixing
indentation.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
